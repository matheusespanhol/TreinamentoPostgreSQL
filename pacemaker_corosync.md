Tutorial de Instalação e Configuração do Pacemaker+Corosync para Alta Disponibilidade do PostgreSQL
===================================================================================================

Material Complementar ao Curso ``PostgreSQL – Alta Disponibilidade''

Instalação do Pacemaker e Corosync no Debian
--------------------------------------------

Todos comandos executados nesse tutorial deveram ser feitos como usuário `root`:

	$ su - root

ou

	$ sudo su - root

Instalação via pacotes:

	apt-get install pacemaker corosync

Apenas em um nó (`postgres01`), copiar o arquivo `/etc/corosync/corosync.conf.example` para `/etc/corosync/corosync.conf`:

	cp /etc/corosync/corosync.conf.example /etc/corosync/corosync.conf

Editar o arquivo `/etc/corosync/corosync.conf` para identificar a sua rede (parâmetro `totem.interface.bindnetaddr`).
O arquivo final, usado no curso, ficará com o seguinte conteúdo:

	compatibility: whitetank
	
	totem {
	   version: 2
	   secauth: off
	   threads: 0
	   interface {
	       ringnumber: 0
	       bindnetaddr: 192.168.56.0
	       mcastaddr: 226.94.1.1
	       mcastport: 4000
	   }
	}
	
	logging {
	   fileline: off
	   to_stderr: yes
	   to_logfile: yes
	   to_syslog: yes
	   logfile: /tmp/corosync.log
	   debug: off
	   timestamp: on
	   logger_subsys {
	      subsys: AMF
	      debug: off
	   }
	}
	
	amf {
	   mode: disabled
	}
	aisexec {
	   user: root
	   group: root
	}
	service {
	   # Load the Pacemaker Cluster Resource Manager (CRM)
	   name: pacemaker
	   ver: 0
	}

Configurar também o corosync para inciar, alterando a variável START para yes em /etc/default/corosync:

	START=yes

Agora, deve-se copiar os arquivos de configuração para os demais nós:

	scp /etc/corosync/* root@postgresql02:/etc/corosync/
	scp /etc/default/corosync/ root@postgresql02:/etc/default/

Em seguida, basta iniciar o Corosync em todos nós:

	/etc/initi.d/corosync start

Para verificar se foi iniciado:

	crm_mon

Deverá resultar em algo semelhante à:

	============
	Last updated: Mon Dec 3 16:30:36 2012
	Stack: openais
	Current DC: postgres01 - partition with quorum
	Version: 1.0.9-89bd754939df5150de7cd76835f98fe90851b677
	2 Nodes configured, 2 expected votes
	0 Resources configured.
	============
	
	Online: [ postgres01 postgres02 ]

Pode demorar um tempo até que os dois nós se encontrem. Pressionar Ctrl+C para fechar.

Configuração do Cluster
-----------------------

A partir de agora, usaremos o utilitário `crm` para configurar o cluster e os serviços do mesmo.
Estas operações devem ser executadas apenas em um servidor, o próprio CRM replica para os demais.

Primeiro, vamos desabilitar o STONITH:

	crm configure property stonith-enabled=false

Caso um serviço rodando, por exemplo, no `postgres01` e o mesmo fique indisponível, o mesmo passará a executar no `postgres02`.
Entretanto, se o `postgres01` voltar a ficar disponível, o Pacemaker retira o servido do 02 e retorna para o 01.
Isso pode causar problemas de sincronia, e para desabilitar (ou seja, mantar no `postgres02`), devemos configurar o seguinte:

	crm configure rsc_defaults resource-stickiness=100

Para desabilitar a política de quorum, que diz que precisa-se de mais da metade dos nós executando para trocar o serviço (ou seja, com 2 nós, caso um caia o outro não irá assumir), usamos o seguinte comando:

	crm configure property no-quorum-policy=ignore

Para verificar as configurações realizadas até então (em qualquer nó):

	node postgres01
	node postgres02
	property $id="cib-bootstrap-options" \
		dc-version="1.0.9-74392a28b7f31d7ddc86689598bd23114f58978b" \
		cluster-infrastructure="openais" \
		expected-quorum-votes="2" \
		stonith-enabled="false" \
		no-quorum-policy="ignore"
	rsc_defaults $id="rsc-options" \
		resource-stickiness="100"

Configurando os serviços
------------------------

### IP Virtual

Para configurar um IP virtual, basta adicionar o serviço OCF:

	crm configure primitive DBIP ocf:heartbeat:IPaddr2 \
	    params \
	    ip="192.168.56.103" cidr_netmask="24" \
	    op monitor interval="30s"

Verificação do serviço rodando:

	# crm_mon
	============
	Last updated: Mon Dec 3 16:41:32 2012
	Stack: openais
	Current DC: postgres01 - partition with quorum
	Version: 1.0.9-89bd754939df5150de7cd76835f98fe90851b677
	2 Nodes configured, 2 expected votes
	1 Resources configured.
	============
	
	Online: [ postgres01 postgres02 ]
	
	  DBIP   (ocf::heartbeat:IPaddr2):       Started postgres01

O mesmo também podia ter iniciado no `postgres02`.

### PostgreSQL

O serviço do PostgreSQL é adicionado da seguinte forma:

	crm configure primitive pgsql ocf:heartbeat:pgsql \
	    params \
	    pgctl="/usr/local/pgsql/bin/pg_ctl" \
	    psql="/usr/local/pgsql/bin/psql" \
	    pgdata="/usr/local/pgsql/data" \
	    pgdba="postgres" pgport="5432"

Verificação:

	# crm_mon
	============
	Last updated: Mon Dec 3 16:41:32 2012
	Stack: openais
	Current DC: postgres01 - partition with quorum
	Version: 1.0.9-89bd754939df5150de7cd76835f98fe90851b677
	2 Nodes configured, 2 expected votes
	2 Resources configured.
	============
	
	Online: [ postgres01 postgres02 ]
	
	  DBIP   (ocf::heartbeat:IPaddr2):       Started postgres01
	  pgsql  (ocf::heartbeat:pgsql):         Started postgres01

### União dos serviços e definição de preferência

Para que os dois serviços sempre executem juntos, devemos realizar a seguinte configuração:

	crm configure colocation pgsql-with-dbip inf: DBIP pgsql

Já para dar preferência ao `postgres01`:

	crm configure location prefer-master pgsql 100: postgres01

Com isso o cluster está configurado.

### Configuração final

A configuração final ficou o seguinte:

	# crm configure show
	node postgres01
	node postgres02
	primitive DBIP ocf:heartbeat:IPaddr2 \
		params ip="192.168.56.103" cidr_netmask="24" \
		op monitor interval="30s"
	primitive pgsql ocf:heartbeat:pgsql \
		params pgctl="/usr/local/pgsql/bin/pg_ctl" psql="/usr/local/pgsql/bin/psql" pgdata="/usr/local/pgsql/data" pgdba="postgres" pgport="5432" logfile="/usr/local/pgsql/serverlog"
	location prefer-master pgsql 100: postgres01
	colocation pgsql-with-dbip inf: DBIP pgsql
	property $id="cib-bootstrap-options" \
		dc-version="1.0.9-74392a28b7f31d7ddc86689598bd23114f58978b" \
		cluster-infrastructure="openais" \
		expected-quorum-votes="2" \
		stonith-enabled="false" \
		no-quorum-policy="ignore"
	rsc_defaults $id="rsc-options" \
		resource-stickiness="100"

Reiniciando tudo
----------------

Em caso de problemas ou para reiniciar os testes, podemos tentar limpar as configurações:

	cibadmin -E --force

Caso não funcione, podemos limpar tudo forçadamente (executar em todos nós):

	/etc/init.d/corosync stop
	killall -9 corosync
	rm -rf /var/lib/heartbeat/crm/*
	/etc/init.d/corosync start

**OBSERVAÇÃO:** estas são operações extremas e não devem ser executadas em ambiente de produção.

