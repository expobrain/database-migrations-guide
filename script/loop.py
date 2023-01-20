# while true loop
#     begin;
#     select * from cities for update limit 10;
#     select pg_sleep(random());
#     rollback
# end loop;


from sqlalchemy import create_engine, text

engine = create_engine(
    "postgresql://postgres:postgres@localhost/test", echo=True, future=True
)

while True:
    print("lock")
    with engine.begin() as conn:
        result = conn.execute(
            text(
                "select * "
                "from cities "
                "where name = concat('city' , trunc(random() * 10000000)) "
                "for update"
            )
        ).all()
        conn.execute(text("select pg_sleep(random())")).all()
        conn.rollback()
