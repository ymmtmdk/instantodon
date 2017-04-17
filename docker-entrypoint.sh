#!/bin/sh

POSTGRES_USER=$DB_USER

chown -R $POSTGRES_USER "$PGDATA"
mkdir -p /run/postgresql
chown -R $POSTGRES_USER /run/postgresql

gosu postgres initdb
sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf

echo "ALTER USER $POSTGRES_USER WITH SUPERUSER;" | gosu postgres postgres --single -jE

# internal start of server in order to allow set-up using psql-client
# does not listen on TCP/IP and waits until start finishes
gosu postgres pg_ctl -D "$PGDATA" -o "-c listen_addresses=''" -w start
gosu postgres pg_ctl -D "$PGDATA" -m fast -w stop

{ echo; echo "host all all 0.0.0.0/0 trust"; } >> "$PGDATA"/pg_hba.conf

gosu postgres postgres &
redis-server &
bundle exec rails db:migrate
bundle exec rails assets:precompile
bundle exec sidekiq -q default -q mailers -q pull -q push &
bundle exec rails s -p 80 -b '0.0.0.0'

