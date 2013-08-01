--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.9
-- Dumped by pg_dump version 9.1.9
-- Started on 2013-07-26 18:09:45 BST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 1996 (class 1262 OID 11951)
-- Dependencies: 1995
-- Name: postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 176 (class 3079 OID 11677)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 1999 (class 0 OID 0)
-- Dependencies: 176
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 175 (class 3079 OID 16385)
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- TOC entry 2000 (class 0 OID 0)
-- Dependencies: 175
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


SET search_path = public, pg_catalog;

--
-- TOC entry 499 (class 1247 OID 16395)
-- Dependencies: 500 6
-- Name: email_address; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN email_address AS character varying(84)
	CONSTRAINT email_address_check CHECK (((VALUE)::text ~ '^[A-Za-z0-9](([_.-]?[a-zA-Z0-9]+)*)@([A-Za-z0-9]+)(([.-]?[a-zA-Z0-9]+)*).([A-Za-z]{2,})$'::text));


ALTER DOMAIN public.email_address OWNER TO postgres;

--
-- TOC entry 188 (class 1255 OID 16397)
-- Dependencies: 6 535
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
-- TOC entry 189 (class 1255 OID 16398)
-- Dependencies: 535 6
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
-- TOC entry 161 (class 1259 OID 16399)
-- Dependencies: 6
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE groups (
    id_group integer NOT NULL,
    label character varying(50) NOT NULL
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- TOC entry 162 (class 1259 OID 16402)
-- Dependencies: 6 161
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
-- TOC entry 2001 (class 0 OID 0)
-- Dependencies: 162
-- Name: groups_id_group_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE groups_id_group_seq OWNED BY groups.id_group;


--
-- TOC entry 163 (class 1259 OID 16404)
-- Dependencies: 6
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
-- TOC entry 164 (class 1259 OID 16410)
-- Dependencies: 6 163
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
-- TOC entry 2002 (class 0 OID 0)
-- Dependencies: 164
-- Name: items_id_item_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE items_id_item_seq OWNED BY items.id_item;


--
-- TOC entry 165 (class 1259 OID 16412)
-- Dependencies: 1933 6
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
-- TOC entry 166 (class 1259 OID 16419)
-- Dependencies: 165 6
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
-- TOC entry 2003 (class 0 OID 0)
-- Dependencies: 166
-- Name: orders_id_order_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE orders_id_order_seq OWNED BY orders.id_order;


--
-- TOC entry 167 (class 1259 OID 16421)
-- Dependencies: 6
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE roles (
    id_role integer NOT NULL,
    label character varying(50) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 168 (class 1259 OID 16424)
-- Dependencies: 6 167
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
-- TOC entry 2004 (class 0 OID 0)
-- Dependencies: 168
-- Name: roles_id_role_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE roles_id_role_seq OWNED BY roles.id_role;


--
-- TOC entry 169 (class 1259 OID 16426)
-- Dependencies: 6
-- Name: rolesngroups; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE rolesngroups (
    id_role integer NOT NULL,
    id_group integer NOT NULL
);


ALTER TABLE public.rolesngroups OWNER TO postgres;

--
-- TOC entry 170 (class 1259 OID 16429)
-- Dependencies: 1936 1937 6
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
-- TOC entry 171 (class 1259 OID 16437)
-- Dependencies: 170 6
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
-- TOC entry 2005 (class 0 OID 0)
-- Dependencies: 171
-- Name: tracks_id_track_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tracks_id_track_seq OWNED BY tracks.id_track;


--
-- TOC entry 172 (class 1259 OID 16439)
-- Dependencies: 1940 6
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
    auth_token character varying(20),
    CONSTRAINT users_id_user_check CHECK ((id_user > (-1)))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 173 (class 1259 OID 16446)
-- Dependencies: 6 172
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
-- TOC entry 2006 (class 0 OID 0)
-- Dependencies: 173
-- Name: users_id_user_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE users_id_user_seq OWNED BY users.id_user;


--
-- TOC entry 174 (class 1259 OID 16448)
-- Dependencies: 6
-- Name: usersngroups; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE usersngroups (
    id_user integer NOT NULL,
    id_group integer NOT NULL
);


ALTER TABLE public.usersngroups OWNER TO postgres;

--
-- TOC entry 1931 (class 2604 OID 16451)
-- Dependencies: 162 161
-- Name: id_group; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY groups ALTER COLUMN id_group SET DEFAULT nextval('groups_id_group_seq'::regclass);


--
-- TOC entry 1932 (class 2604 OID 16452)
-- Dependencies: 164 163
-- Name: id_item; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY items ALTER COLUMN id_item SET DEFAULT nextval('items_id_item_seq'::regclass);


--
-- TOC entry 1934 (class 2604 OID 16453)
-- Dependencies: 166 165
-- Name: id_order; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders ALTER COLUMN id_order SET DEFAULT nextval('orders_id_order_seq'::regclass);


--
-- TOC entry 1935 (class 2604 OID 16454)
-- Dependencies: 168 167
-- Name: id_role; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY roles ALTER COLUMN id_role SET DEFAULT nextval('roles_id_role_seq'::regclass);


--
-- TOC entry 1938 (class 2604 OID 16455)
-- Dependencies: 171 170
-- Name: id_track; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tracks ALTER COLUMN id_track SET DEFAULT nextval('tracks_id_track_seq'::regclass);


--
-- TOC entry 1939 (class 2604 OID 16456)
-- Dependencies: 173 172
-- Name: id_user; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN id_user SET DEFAULT nextval('users_id_user_seq'::regclass);


--
-- TOC entry 1977 (class 0 OID 16399)
-- Dependencies: 161 1991
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY groups (id_group, label) FROM stdin;
\.


--
-- TOC entry 2007 (class 0 OID 0)
-- Dependencies: 162
-- Name: groups_id_group_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('groups_id_group_seq', 1, false);


--
-- TOC entry 1979 (class 0 OID 16404)
-- Dependencies: 163 1991
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY items (id_item, id_order, item_name, item_number, mc_gross_) FROM stdin;
7	30	Hitmaker-HorrorJingle	171	109.00
8	31	Hitmaker-HorrorJingle	171	109.00
9	34	Hitmaker-HorrorJingle	171	109.00
10	35	Faiby - Beware	172	85.00
11	35	SW-znelka	175	15.00
12	36	Solarni-studio-Naomi	176	92.00
13	36	SW-znelka	175	15.00
17	38	SW-znelka	175	15.00
24	41	SW-znelka	175	15.00
28	43	Hitmaker-HorrorJingle	171	50.00
\.


--
-- TOC entry 2008 (class 0 OID 0)
-- Dependencies: 164
-- Name: items_id_item_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('items_id_item_seq', 43, true);


--
-- TOC entry 1981 (class 0 OID 16412)
-- Dependencies: 165 1991
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY orders (id_order, txn_id, id_user, "timestamp") FROM stdin;
35	0L4123907H326274J	58	2013-07-11 12:01:36.491166
36	8DS64131MV187271J	58	2013-07-11 12:01:36.491166
43	54C32860WG912300F	58	2013-07-22 21:01:36.491166
41	45C90888WT7168213	58	2013-07-18 12:01:36.491166
38	5PM897582L013601B	58	2013-07-13 12:01:36.491166
34	93L547953M308705S	58	2013-07-09 12:01:36.491166
31	5B9757284K6248317	58	2013-07-05 12:01:36.491166
30	1XU26221DM2641933	58	2013-06-11 12:01:36.491166
\.


--
-- TOC entry 2009 (class 0 OID 0)
-- Dependencies: 166
-- Name: orders_id_order_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('orders_id_order_seq', 48, true);


--
-- TOC entry 1983 (class 0 OID 16421)
-- Dependencies: 167 1991
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY roles (id_role, label) FROM stdin;
\.


--
-- TOC entry 2010 (class 0 OID 0)
-- Dependencies: 168
-- Name: roles_id_role_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('roles_id_role_seq', 3, true);


--
-- TOC entry 1985 (class 0 OID 16426)
-- Dependencies: 169 1991
-- Data for Name: rolesngroups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY rolesngroups (id_role, id_group) FROM stdin;
\.


--
-- TOC entry 1986 (class 0 OID 16429)
-- Dependencies: 170 1991
-- Data for Name: tracks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tracks (id_track, price, exclusive, id_user, id_soundcloud, count_orders) FROM stdin;
173	144	1	58	44957701	0
176	92	1	58	77477486	1
175	15	2	58	77477636	4
171	50	2	58	77477570	4
172	85	1	58	77477331	1
\.


--
-- TOC entry 2011 (class 0 OID 0)
-- Dependencies: 171
-- Name: tracks_id_track_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tracks_id_track_seq', 177, true);


--
-- TOC entry 1988 (class 0 OID 16439)
-- Dependencies: 172 1991
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY users (id_user, email, password, id_soundcloud, soundcloud_oauth_token, paypal_email, address_company_name, address_number_street, address_town, address_zip, pwd_reset_token, pwd_reset_timestamp) FROM stdin;
59	info@hitmaker.cz	ddfe9964a5f8d6f74d35dbde9b3a54f1735bc8b8	4815894	1-32399-4815894-a77357f78f4682af	bruckner.roman-facilitator@gmail.com	\N	\N	\N	\N	\N	\N
58	bruckner.roman@gmail.com	153901d37c675ffe9a1eb5ef01a8199930b2d48b	16187306	1-32399-16187306-fc61e52faf02429	bruckner.roman-facilitator@gmail.com	\N	\N	\N	\N		1374856818
\.


--
-- TOC entry 2012 (class 0 OID 0)
-- Dependencies: 173
-- Name: users_id_user_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('users_id_user_seq', 59, true);


--
-- TOC entry 1990 (class 0 OID 16448)
-- Dependencies: 174 1991
-- Data for Name: usersngroups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY usersngroups (id_user, id_group) FROM stdin;
\.


--
-- TOC entry 1942 (class 2606 OID 16458)
-- Dependencies: 161 161 1992
-- Name: groups_label_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_label_key UNIQUE (label);


--
-- TOC entry 1944 (class 2606 OID 16460)
-- Dependencies: 161 161 1992
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id_group);


--
-- TOC entry 1948 (class 2606 OID 16462)
-- Dependencies: 163 163 1992
-- Name: id_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY items
    ADD CONSTRAINT id_item_pkey PRIMARY KEY (id_item);


--
-- TOC entry 1950 (class 2606 OID 16464)
-- Dependencies: 165 165 1992
-- Name: id_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT id_user_pkey PRIMARY KEY (id_order);


--
-- TOC entry 1954 (class 2606 OID 16466)
-- Dependencies: 167 167 1992
-- Name: roles_label_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_label_key UNIQUE (label);


--
-- TOC entry 1956 (class 2606 OID 16468)
-- Dependencies: 167 167 1992
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id_role);


--
-- TOC entry 1958 (class 2606 OID 16470)
-- Dependencies: 169 169 169 1992
-- Name: rolesngroups_id_role_id_group_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rolesngroups
    ADD CONSTRAINT rolesngroups_id_role_id_group_key UNIQUE (id_role, id_group);


--
-- TOC entry 1960 (class 2606 OID 16472)
-- Dependencies: 170 170 1992
-- Name: tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (id_track);


--
-- TOC entry 1952 (class 2606 OID 16474)
-- Dependencies: 165 165 1992
-- Name: txn_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT txn_id_unique UNIQUE (txn_id);


--
-- TOC entry 1962 (class 2606 OID 16476)
-- Dependencies: 172 172 1992
-- Name: users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 1964 (class 2606 OID 16478)
-- Dependencies: 172 172 1992
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_user);


--
-- TOC entry 1966 (class 2606 OID 16480)
-- Dependencies: 174 174 174 1992
-- Name: usersngroups_id_user_id_group_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usersngroups
    ADD CONSTRAINT usersngroups_id_user_id_group_key UNIQUE (id_user, id_group);


--
-- TOC entry 1945 (class 1259 OID 16481)
-- Dependencies: 163 1992
-- Name: fki_id_order_fkey; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fki_id_order_fkey ON items USING btree (id_order);


--
-- TOC entry 1946 (class 1259 OID 16482)
-- Dependencies: 163 1992
-- Name: fki_item_number_fkey; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fki_item_number_fkey ON items USING btree (item_number);


--
-- TOC entry 1975 (class 2620 OID 16483)
-- Dependencies: 188 170 1992
-- Name: body; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER body BEFORE DELETE OR UPDATE ON tracks FOR EACH ROW EXECUTE PROCEDURE check_count_orders();


--
-- TOC entry 1976 (class 2620 OID 16484)
-- Dependencies: 170 188 1992
-- Name: check_count_orders; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_count_orders BEFORE DELETE OR UPDATE ON tracks FOR EACH ROW EXECUTE PROCEDURE check_count_orders();


--
-- TOC entry 1974 (class 2620 OID 16485)
-- Dependencies: 189 163 1992
-- Name: inc_count_orders; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER inc_count_orders BEFORE INSERT ON items FOR EACH ROW EXECUTE PROCEDURE inc_count_orders();


--
-- TOC entry 1967 (class 2606 OID 16486)
-- Dependencies: 165 1949 163 1992
-- Name: id_order_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY items
    ADD CONSTRAINT id_order_fkey FOREIGN KEY (id_order) REFERENCES orders(id_order) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1969 (class 2606 OID 16491)
-- Dependencies: 165 1963 172 1992
-- Name: id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT id_user_fkey FOREIGN KEY (id_user) REFERENCES users(id_user);


--
-- TOC entry 1968 (class 2606 OID 16496)
-- Dependencies: 1959 170 163 1992
-- Name: item_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY items
    ADD CONSTRAINT item_number_fkey FOREIGN KEY (item_number) REFERENCES tracks(id_track) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 1970 (class 2606 OID 16501)
-- Dependencies: 1943 169 161 1992
-- Name: rolesngroups_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rolesngroups
    ADD CONSTRAINT rolesngroups_id_group_fkey FOREIGN KEY (id_group) REFERENCES groups(id_group) ON DELETE CASCADE;


--
-- TOC entry 1971 (class 2606 OID 16506)
-- Dependencies: 169 167 1955 1992
-- Name: rolesngroups_id_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rolesngroups
    ADD CONSTRAINT rolesngroups_id_role_fkey FOREIGN KEY (id_role) REFERENCES roles(id_role) ON DELETE CASCADE;


--
-- TOC entry 1972 (class 2606 OID 16511)
-- Dependencies: 174 161 1943 1992
-- Name: usersngroups_id_group_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usersngroups
    ADD CONSTRAINT usersngroups_id_group_fkey FOREIGN KEY (id_group) REFERENCES groups(id_group) ON DELETE CASCADE;


--
-- TOC entry 1973 (class 2606 OID 16516)
-- Dependencies: 1963 174 172 1992
-- Name: usersngroups_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usersngroups
    ADD CONSTRAINT usersngroups_id_user_fkey FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE;


--
-- TOC entry 1998 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2013-07-26 18:09:45 BST

--
-- PostgreSQL database dump complete
--

