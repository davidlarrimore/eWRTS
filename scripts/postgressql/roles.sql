-- DROP ROLE anon;
-- DROP ROLE authenticator;
-- DROP ROLE api_user;

CREATE ROLE anon WITH
  NOLOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION;


CREATE ROLE authenticator WITH
  LOGIN
  NOSUPERUSER
  NOINHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION;


CREATE ROLE api_user WITH
  NOLOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION;

GRANT anon, api_user, author TO authenticator;

grant usage on schema public to authenticator;
grant select on public.cis2 to authenticator;

grant usage on schema public to anon;
grant select on public.cis2 to anon;
grant select on public.rails to anon;

grant usage on schema public to api_user;
grant all on public.cis2 to api_user;
grant all on public.rails to api_user;
