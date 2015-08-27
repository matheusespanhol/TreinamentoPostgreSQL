Instalação do PostgreSQL via código fonte
=========================================

OBS: Linhas iniciadas com >>> são comentários ou saída de comandos. Linhas iniciadas com $ são usuários não privilegiados e começados com # são de root.

Logar como root:

	$ su - root
	
OBS: Para alguns ambientes (como o padrão do Ubuntu), pode ser necessário usar: `sudo su -`.

Instalar dependências:

	# apt-get install libreadline6-dev zlib1g-dev build-essential

Baixando, extraindo e compilando o PostgreSQL:

	# cd /usr/local/src/
	# wget https://ftp.postgresql.org/pub/source/v9.4.4/postgresql-9.4.4.tar.bz2
	# tar jxvf postgresql-9.4.4.tar.bz2
	# cd postgresql-9.4.4/
	# ./configure --prefix=/usr/local/pgsql-9.4.4
	# make -j 2  # trocar 2 pelo número de cores
	# make install

Link simbólico (facilita administração e atualizações):

	# cd /usr/local/
	# ln -s pgsql-9.4.4/ pgsql

Variáveis de ambiente:

	# gedit /etc/profile
	>>> Adicionar as linhas no final:
	    export PATH=/usr/local/pgsql/bin:$PATH
	    export LD_LIBRARY_PATH=/usr/local/pgsql/lib:$LD_LIBRARY_PATH
	    export PGDATA=/postgres/data

OBS: O arquivo `/etc/profile` requer um logout/login no sistema para aplicar, ou (para a sessão corrente):

	# source /etc/profile

Adicionar usuário `postgres`:

	# adduser postgres

Criação do diretório de dados:

	# mkdir /postgres
	# chown -R postgres. -R /postgres

Criação do cluster:

	# su - postgres
	$ initdb
	$ logout

Script de inicialização:

	# cp /usr/local/src/postgresql-9.4.4/contrib/start-scripts/linux /etc/init.d/postgresql
	# chmod a+x /etc/init.d/postgresql
	# update-rc.d postgresql defaults

Iniciar o PostgreSQL:

	# /etc/init.d/postgresql start
	# tail /usr/local/pgsql/data/serverlog

