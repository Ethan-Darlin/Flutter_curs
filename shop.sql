create table if not exists users
(
    id          serial
        constraint users_pk
            primary key,
    name        text,
    password    text,
    login       text
        constraint users_pk2
            unique,
    phonenumber text,
    role        text,
    user_image text
);

alter table users
    owner to shopuser;

create table if not exists items
(
    id          serial
        constraint items_pk
            primary key,
    name        text,
    description text,
    cost        integer,
    count       integer,
    image       text,
    category    text
);

alter table items
    owner to shopuser;

create table if not exists point_of_issue
(
    id     serial
        constraint point_of_issue_pk
            primary key,
    name   text,
    adress text
);

alter table point_of_issue
    owner to shopuser;

create table if not exists orders
(
    id         serial
        constraint orders_pk
            primary key,
    point_id   integer
        constraint orders_point_of_issue_id_fk
            references point_of_issue,
    user_id    integer
        constraint orders_users_id_fk
            references users
            on update cascade on delete cascade,
    status     text,
    created_at timestamp
);

alter table orders
    owner to shopuser;

create table if not exists order_details
(
    id       serial
        constraint order_details_pk
            primary key,
    order_id integer
        constraint order_details_orders_id_fk
            references orders,
    item_id  integer
        constraint order_details_items_id_fk
            references items,
    count    integer
);

alter table order_details
    owner to shopuser;

create or replace function login(p_login text, p_password text)
    returns TABLE(login text, name text, phonenumber text, role text, id integer)
    security definer
    language plpgsql
as
$$
DECLARE
    v_status int;
BEGIN

    select count(users.id) into v_status from users where users.login = p_login and users.password = p_password;

    IF v_status <= 0 THEN
        Raise exception 'User doesnt exist!';
    end if;

    return query select users.login, users.name, users.phonenumber, users.role, users.id
                 from users where users.login = p_login and users.password = p_password;
END;
$$;

alter function login(text, text) owner to shopuser;

create or replace function create_new_user(p_login character varying, p_password character varying, p_phonenumber character varying, p_name character varying) returns boolean
    language plpgsql
as
$$
DECLARE
  v_role VARCHAR(20) := 'customer'; -- устанавливаем роль по умолчанию
  user_id int;
BEGIN
  -- проверяем, есть ли уже пользователь с таким же логином или номером телефона
  IF EXISTS (SELECT 1 FROM users WHERE login = p_login OR phonenumber = p_phonenumber) THEN
    RETURN FALSE;
  END IF;

  -- добавляем нового пользователя
  INSERT INTO users (name, password, login, phonenumber, role)
  VALUES (p_name, p_password, p_login, p_phonenumber, v_role) returning id into user_id;

  RETURN TRUE;
END;
$$;

alter function create_new_user(varchar, varchar, varchar, varchar) owner to shopuser;

create or replace function create_new_point_of_issue(p_name text, p_address text) returns boolean
    language plpgsql
as
$$
BEGIN
  -- проверяем, не существует ли уже точка выдачи с таким же именем
  IF EXISTS (SELECT 1 FROM point_of_issue WHERE name = p_name) THEN
    RETURN FALSE;
  END IF;

  -- добавляем новую точку выдачи в таблицу point_of_issue
  INSERT INTO point_of_issue (name, adress)
  VALUES (p_name, p_address);

  RETURN TRUE;
END;
$$;

alter function create_new_point_of_issue(text, text) owner to shopuser;

create or replace function delete_item_by_name(item_name character varying) returns void
    language plpgsql
as
$$
BEGIN
    DELETE FROM items WHERE name = item_name;
END;
$$;

alter function delete_item_by_name(varchar) owner to shopuser;

create or replace function get_order_items(p_order_id integer)
    returns TABLE(item_id integer, item_name text, item_cost integer)
    language plpgsql
as
$$
BEGIN
    RETURN QUERY select items.id, items.name, items.cost
                 from items inner join order_details on items.id = order_details.item_id
                            inner join orders on orders.id = order_details.order_id
                 where orders.id = p_order_id;
END;
$$;

alter function get_order_items(integer) owner to shopuser;

create or replace function create_order(p_point_id integer, p_user_id integer) returns integer
    language plpgsql
as
$$DECLARE
        v_order_id int;
Begin

        insert into orders (point_id, user_id, status, created_at) values(p_point_id, p_user_id, 'created', now()) returning orders.id into v_order_id;
        return v_order_id;

end

    $$;

alter function create_order(integer, integer) owner to shopuser;

create or replace function add_detail_to_order(p_item_id integer, p_order_id integer, p_count integer) returns void
    language plpgsql
as
$$
DECLARE
    v_item_count INT;
    v_item_id INT;
    v_detail_id INT;
    v_last_item_count INT;
BEGIN
    INSERT INTO order_details (order_id, item_id, count)
    VALUES (p_order_id, p_item_id, p_count)
    RETURNING id INTO v_detail_id;

    SELECT order_details.count, order_details.item_id
    INTO v_item_count, v_item_id
    FROM order_details
    WHERE id = v_detail_id;

    SELECT items.count INTO v_last_item_count
    FROM items
    WHERE items.id = v_item_id;

    IF v_last_item_count - v_item_count < 0 THEN
        RAISE EXCEPTION 'COUNT ITEM ERROR';
    END IF;

    UPDATE items
    SET count = v_last_item_count - v_item_count
    WHERE id = v_item_id;
END;
$$;

alter function add_detail_to_order(integer, integer, integer) owner to shopuser;

create or replace function get_all_point_of_issue()
    returns TABLE(id integer, name text, adress text)
    language plpgsql
as
$$
BEGIN
  RETURN QUERY SELECT point_of_issue.id, point_of_issue.name, point_of_issue.adress FROM point_of_issue;
END;
$$;

alter function get_all_point_of_issue() owner to shopuser;

create or replace function get_order_details(p_order_id integer)
    returns TABLE(order_id integer, item_id integer, name text, cost integer, count integer, total integer)
    language plpgsql
as
$$
    DECLARE
        Begin
        return query
            select order_details.order_id, order_details.item_id, i.name, i.cost,
                   order_details.count, (i.cost * order_details.count) as total
            from order_details inner join items i on i.id = order_details.item_id
            where order_details.order_id = p_order_id;
        end;
    $$;

alter function get_order_details(integer) owner to shopuser;

create or replace function get_user_orders(p_user_id integer)
    returns TABLE(orders_id integer, point_id integer, user_id integer, user_phone text, status text, created_at timestamp without time zone, poi_name text, poi_adress text)
    language plpgsql
as
$$
    DECLARE
        Begin

            IF p_user_id = -1 THEN
                return query select orders.id, orders.point_id, orders.user_id, u.phonenumber, orders.status, orders.created_at, poi.name, poi.adress
                         from orders inner join point_of_issue poi on orders.point_id = poi.id
                                        inner join users u on u.id = orders.user_id
                                        order by orders.created_at desc;
                ELSE
                return query select orders.id, orders.point_id, orders.user_id, u.phonenumber, orders.status, orders.created_at, poi.name, poi.adress
                         from orders inner join point_of_issue poi on orders.point_id = poi.id
                                        inner join users u on u.id = orders.user_id where orders.user_id = p_user_id
                                        order by orders.created_at desc;
            end if;


        end;
    $$;

alter function get_user_orders(integer) owner to shopuser;

create or replace function update_order_status(p_order_id integer, p_order_status text) returns void
    language plpgsql
as
$$

    DECLARE

        Begin
            update orders set status = p_order_status where orders.id = p_order_id;
        end;

    $$;

alter function update_order_status(integer, text) owner to shopuser;

create or replace function add_item(new_name text, new_description text, new_cost numeric, new_count integer, new_category text, new_image text) returns void
    language plpgsql
as
$$
BEGIN
  INSERT INTO items(name, description, cost, count, category, image)
  VALUES(new_name, new_description, new_cost, new_count, new_category, new_image);
END;
$$;

alter function add_item(text, text, numeric, integer, text, text) owner to shopuser;

create or replace function get_all_items()
    returns TABLE(id integer, name text, description text, cost integer, count integer, category text, image text)
    language plpgsql
as
$$
BEGIN
    RETURN QUERY SELECT items.id, items.name, items.description, items.cost, items.count, items.category, items.image FROM items;
END;
$$;

alter function get_all_items() owner to shopuser;

