# while true loop
#     begin;
#     select * from cities for update limit 10;
#     select pg_sleep(random());
#     rollback
# end loop;


from sqlalchemy import create_engine
engine = create_engine("postgresql://postgres:postgres@localhost/test", echo=True, future=True)
