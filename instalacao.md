Instalação do PostgreSQL via código fonte
=========================================

Este é um passo a passo para instalação do PostgreSQL (versão 9.3.1) via código-fonte utilizando as máquinas virtuais disponibilizadas no treinamento. No caso, a VM está utilizando Debian 6, mas há poucas diferenças para outras distribuições (no passo a passo comentamos ao menos para Ubuntu e CentOS/RHEL).

OBS: Linhas iniciadas com >>> são comentários ou saída de comandos. Linhas iniciadas com $ são usuários não privilegiados e começados com # são de root.

OBS2: Para edição de arquivos, utilizamos o comando `gedit`, por ser uma interface mais amigável. Mas recomendo o uso do `vim` (para quem estiver disposto a aprender, =P ), pois o `gedit` não estará disponível em servidores sem ambiente gráfico.

Logar como root:

	$ su - root
	>>> Senha: 1234

OBS: Para alguns ambientes (como o padrão do Ubuntu), pode ser necessário usar: `sudo su - root`.

Instalar dependências:

	# apt-get install libreadline6-dev zlib1g-dev build-essential

Para CentOS/RHEL: `yum install readline-devel zlib-devel gcc make`.

Baixando, extraindo e compilando o PostgreSQL:

	# cd /usr/local/src/
	# wget http://ftp.postgresql.org/pub/source/v9.3.1/postgresql-9.3.1.tar.bz2
	# tar xvf postgresql-9.3.1.tar.bz2
	# cd postgresql-9.3.1/
	# ./configure --prefix=/usr/local/pgsql-9.3.1
	# make -j 2  # trocar 2 pelo número de cores
	# make install

Link simbólico (facilita administração e atualizações):

	# cd /usr/local/
	# ln -s pgsql-9.3.1/ pgsql

Variáveis de ambiente:

	# gedit /etc/profile
	>>> Adicionar as linhas no final:
	    export PATH=/usr/local/pgsql/bin:$PATH
	    export LD_LIBRARY_PATH=/usr/local/pgsql/lib:$LD_LIBRARY_PATH

OBS: O arquivo `/etc/profile` requer um logout/login no sistema para aplicar, ou (para a sessão corrente):

	# source /etc/profile

Adicionar usuário `postgres`:

	# adduser --system --group --shell=/bin/bash postgres

Criação do diretório de dados:

	# mkdir /usr/local/pgsql/data
	# chown -R postgres:postgres /usr/local/pgsql/data

Criação do cluster:

	# su - postgres
	$ initdb -D /usr/local/pgsql/data
	$ logout

Script de inicialização:

	# cp /usr/local/src/postgresql-9.3.1/contrib/start-scripts/linux /etc/init.d/postgresql
	# chmod a+x /etc/init.d/postgresql
	# update-rc.d postgresql defaults

Iniciar o PostgreSQL:

	# /etc/init.d/postgresql start
	# tail /usr/local/pgsql/data/serverlog

