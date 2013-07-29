--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


SET search_path = public, pg_catalog;

--
-- Name: email_address; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN email_address AS character varying(84)
	CONSTRAINT email_address_check CHECK (((VALUE)::text ~ '^[A-Za-z0-9](([_.-]?[a-zA-Z0-9]+)*)@([A-Za-z0-9]+)(([.-]?[a-zA-Z0-9]+)*).([A-Za-z]{2,})$'::text));


ALTER DOMAIN public.email_address OWNER TO postgres;

--
-- Name: check_count_orders(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION check_count_orders() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
	IF (TG_OP = 'DELETE') THEN
		IF (OLD.count_orders > 0) THEN
			RAISE EXCEPTION 'Track can not be deleted. An order containing this track exists.';
			END IF;
                RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
		IF (OLD.count_orders > 0 AND NEW.exclusive = 2) THEN
			RAISE EXCEPTION 'Track can not be exclusive. An order already exists.';
			END IF;
            RETURN NEW;                    
	END IF;
END;$$;


ALTER FUNCTION public.check_count_orders() OWNER TO postgres;

--
-- Name: inc_count_orders(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION inc_count_orders() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
	UPDATE tracks SET count_orders = count_orders + 1 WHERE id_track = NEW.item_number;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.inc_count_orders() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE groups (
    id_group integer NOT NULL,
    label character varying(50) NOT NULL
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: groups_id_group_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE groups_id_group_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.groups_id_group_seq OWNER TO postgres;

--
-- Name: groups_id_group_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE groups_id_group_seq OWNED BY groups.id_group;


--
-- Name: items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE items (
    id_item integer NOT NULL,
    id_order integer,
    item_name character varying,
    item_number integer,
    mc_gross_ numeric
);


ALTER TABLE public.items OWNER TO postgres;

--
-- Name: items_id_item_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE items_id_item_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.items_id_item_seq OWNER TO postgres;

--
-- Name: items_id_item_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE items_id_item_seq OWNED BY items.id_item;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE orders (
    id_order integer NOT NULL,
    txn_id character varying,
    id_user integer,
    "timestamp" timestamp without time zone DEFAULT now(),
    secret_token character varying(20)
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_id_order_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE orders_id_order_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_order_seq OWNER TO postgres;

--
-- Name: orders_id_order_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE orders_id_order_seq OWNED BY orders.id_order;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE roles (
    id_role integer NOT NULL,
    label character varying(50) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_role_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE roles_id_role_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_role_seq OWNER TO postgres;

--
-- Name: roles_id_role_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE roles_id_role_seq OWNED BY roles.id_role;


--
-- Name: rolesngroups; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE rolesngroups (
    id_role integer NOT NULL,
    id_group integer NOT NULL
);


ALTER TABLE public.rolesngroups OWNER TO postgres;

--
-- Name: tracks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tracks (
    id_track integer NOT NULL,
    price numeric,
    exclusive smallint DEFAULT 0 NOT NULL,
    id_user integer,
    id_soundcloud integer,
    count_orders integer DEFAULT 0
);


ALTER TABLE public.tracks OWNER TO postgres;

--
-- Name: tracks_id_track_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tracks_id_track_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tracks_id_track_seq OWNER TO postgres;

--
-- Name: tracks_id_track_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tracks_id_track_seq OWNED BY tracks.id_track;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    id_user integer NOT NULL,
    email character varying(200) NOT NULL,
    password character varying(50),
    id_soundcloud integer,
    soundcloud_oauth_token character varying,
    paypal_email character varying(200),
    address_company_name character varying(200),
    address_number_street character varying(200),
    address_town character varying(100),
    address_zip character varying(10),
    pwd_reset_token character varying(23),
    pwd_reset_timestamp integer,
    CONSTRAINT users_id_user_check CHECK ((id_user > (-1)))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_user_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE users_id_user_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_user_seq OWNER TO postgres;

--
-- Name: users_id_user_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE users_id_user_seq OWNED BY users.id_user;


--
-- Name: usersngroups; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE usersngroups (
    id_user integer NOT NULL,
    id_group integer NOT NULL
);


ALTER TABLE public.usersngroups OWNER TO postgres;

--
-- Name: id_group; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY groups ALTER COLUMN id_group SET DEFAULT nextval('groups_id_group_seq'::regclass);


--
-- Name: id_item; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY items ALTER COLUMN id_item SET DEFAULT nextval('items_id_item_seq'::regclass);


--
-- Name: id_order; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders ALTER COLUMN id_order SET DEFAULT nextval('orders_id_order_seq'::regclass);


--
-- Name: id_role; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY roles ALTER COLUMN id_role SET DEFAULT nextval('roles_id_role_seq'::regclass);


--
-- Name: id_track; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tracks ALTER COLUMN id_track SET DEFAULT nextval('tracks_id_track_seq'::regclass);


--
-- Name: id_user; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN id_user SET DEFAULT nextval('users_id_user_seq'::regclass);


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: groups_id_group_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('groups_id_group_seq', 1, false);


--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO items (id_item, id_order, item_name, item_number, mc_gross_) VALUES (7, 30, 'Hitmaker-HorrorJingle', 171, 109.00);
INSERT INTO items (id_item, id_order, item_name, item_number, mc_gross_) VALUES (8, 31, 'Hitmaker-HorrorJingle', 171, 109.00);
INSERT INTO items (id_item, id_order, item_name, item_number, mc_gross_) VALUES (9, 34, 'Hitmaker-HorrorJingle', 171, 109.00);
INSERT INTO items (id_item, id_order, item_name, item_number, mc_gross_) VALUES (10, 35, 'Faiby - Beware', 172, 85.00);
INSERT INTO items (id_item, id_order, item_name, item_number, mc_gross_) VALUES (11, 35, 'SW-znelka', 175, 15.00);
INSERT INTO items (id_item, id_order, item_name, item_number, mc_gross_) VALUES (12, 36, 'Solarni-studio-Naomi', 176, 92.00);
INSERT INTO items (id_item, id_order, item_name, item_number, mc_gross_) VALUES (13, 36, 'SW-znelka', 175, 15.00);
INSERT INTO items (id_item, id_order, item_name, item_number, mc_gross_) VALUES (17, 38, 'SW-znelka', 175, 15.00);
INSERT INTO items (id_item, id_order, item_name, item_number, mc_gross_) VALUES (24, 41, 'SW-znelka', 175, 15.00);
INSERT INTO items (id_item, id_order, item_name, item_number, mc_gross_) VALUES (28, 43, 'Hitmaker-HorrorJingle', 171, 50.00);


--
-- Name: items_id_item_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('items_id_item_seq', 43, true);


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO orders (id_order, txn_id, id_user, "timestamp") VALUES (35, '0L4123907H326274J', 58, '2013-07-11 12:01:36.491166');
INSERT INTO orders (id_order, txn_id, id_user, "timestamp") VALUES (36, '8DS64131MV187271J', 58, '2013-07-11 12:01:36.491166');
INSERT INTO orders (id_order, txn_id, id_user, "timestamp") VALUES (43, '54C32860WG912300F', 58, '2013-07-22 21:01:36.491166');
INSERT INTO orders (id_order, txn_id, id_user, "timestamp") VALUES (41, '45C90888WT7168213', 58, '2013-07-18 12:01:36.491166');
INSERT INTO orders (id_order, txn_id, id_user, "timestamp") VALUES (38, '5PM897582L013601B', 58, '2013-07-13 12:01:36.491166');
INSERT INTO orders (id_order, txn_id, id_user, "timestamp") VALUES (34, '93L547953M308705S', 58, '2013-07-09 12:01:36.491166');
INSERT INTO orders (id_order, txn_id, id_user, "timestamp") VALUES (31, '5B9757284K6248317', 58, '2013-07-05 12:01:36.491166');
INSERT INTO orders (id_order, txn_id, id_user, "timestamp") VALUES (30, '1XU26221DM2641933', 58, '2013-06-11 12:01:36.491166');


--
-- Name: orders_id_order_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('orders_id_order_seq', 48, true);


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: roles_id_role_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('roles_id_role_seq', 3, true);


--
-- Data for Name: rolesngroups; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tracks; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO tracks (id_track, price, exclusive, id_user, id_soundcloud, count_orders) VALUES (173, 144, 1, 58, 44957701, 0);
INSERT INTO tracks (id_track, price, exclusive, id_user, id_soundcloud, count_orders) VALUES (176, 92, 1, 58, 77477486, 1);
INSERT INTO tracks (id_track, price, exclusive, id_user, id_soundcloud, count_orders) VALUES (175, 15, 2, 58, 77477636, 4);
INSERT INTO tracks (id_track, price, exclusive, id_user, id_soundcloud, count_orders) VALUES (171, 50, 2, 58, 77477570, 4);
INSERT INTO tracks (id_track, price, exclusive, id_user, id_soundcloud, count_orders) VALUES (172, 85, 1, 58, 77477331, 1);


--
-- Name: tracks_id_track_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tracks_id_track_seq', 177, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO users (id_user, email, password, id_soundcloud, soundcloud_oauth_token, paypal_email, address_company_name, address_number_street, address_town, address_zip, pwd_reset_token, pwd_reset_timestamp) VALUES (59, 'info@hitmaker.cz', 'ddfe9964a5f8d6f74d35dbde9b3a54f1735bc8b8', 4815894, '1-32399-4815894-a77357f78f4682af', 'bruckner.roman-facilitator@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO users (id_user, email, password, id_soundcloud, soundcloud_oauth_token, paypal_email, address_company_name, address_number_street, address_town, address_zip, pwd_reset_token, pwd_reset_timestamp) VALUES (58, 'bruckner.roman@gmail.com', '153901d37c675ffe9a1eb5ef01a8199930b2d48b', 16187306, '1-32399-16187306-fc61e52faf02429', 'bruckner.roman-facilitator@gmail.com', NULL, NULL, NULL, NULL, '', 1374856818);


--
-- Name: users_id_user_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('users_id_user_seq', 59, true);


--
-- Data for Name: usersngroups; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: groups_label_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_label_key UNIQUE (label);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id_group);


--
-- Name: id_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY items
    ADD CONSTRAINT id_item_pkey PRIMARY KEY (id_item);


--
-- Name: id_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT id_user_pkey PRIMARY KEY (id_order);


--
-- Name: roles_label_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_label_key UNIQUE (label);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id_role);


--
-- Name: rolesngroups_id_role_id_group_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rolesngroups
    ADD CONSTRAINT rolesngroups_id_role_id_group_key UNIQUE (id_role, id_group);


--
-- Name: tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (id_track);


--
-- Name: txn_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT txn_id_unique UNIQUE (txn_id);


--
-- Name: users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_user);


--
-- Name: usersngroups_id_user_id_group_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usersngroups
    ADD CONSTRAINT usersngroups_id_user_id_group_key UNIQUE (id_user, id_group);


--
-- Name: fki_id_order_fkey; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fki_id_order_fkey ON items USING btree (id_order);


--
-- Name: fki_item_number_fkey; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fki_item_number_fkey ON items USING btree (item_number);


--
-- Name: body; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER body BEFORE DELETE OR UPDATE ON tracks FOR EACH ROW EXECUTE PROCEDURE check_count_orders();


--
-- Name: check_count_orders; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_count_orders BEFORE DELETE OR UPDATE ON tracks FOR EACH ROW EXECUTE PROCEDURE check_count_orders();


--
-- Name: inc_count_orders; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER inc_count_orders BEFORE INSERT ON items FOR EACH ROW EXECUTE PROCEDURE inc_count_orders();


--
-- Name: id_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY items
    ADD CONSTRAINT id_order_fkey FOREIGN KEY (id_order) REFERENCES orders(id_order) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT id_user_fkey FOREIGN KEY (id_user) REFERENCES users(id_user);


--
-- Name: item_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY items
    ADD CONSTRAINT item_number_fkey FOREIGN KEY (item_number) REFERENCES tracks(id_track) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: rolesngroups_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rolesngroups
    ADD CONSTRAINT rolesngroups_id_group_fkey FOREIGN KEY (id_group) REFERENCES groups(id_group) ON DELETE CASCADE;


--
-- Name: rolesngroups_id_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rolesngroups
    ADD CONSTRAINT rolesngroups_id_role_fkey FOREIGN KEY (id_role) REFERENCES roles(id_role) ON DELETE CASCADE;


--
-- Name: usersngroups_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usersngroups
    ADD CONSTRAINT usersngroups_id_group_fkey FOREIGN KEY (id_group) REFERENCES groups(id_group) ON DELETE CASCADE;


--
-- Name: usersngroups_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usersngroups
    ADD CONSTRAINT usersngroups_id_user_fkey FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

