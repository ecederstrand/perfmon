--
-- PostgreSQL database dump
--

-- Started on 2008-01-23 14:29:29 CET

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 1668 (class 1262 OID 16389)
-- Name: perfmon; Type: DATABASE; Schema: -; Owner: erik
--

CREATE DATABASE perfmon WITH TEMPLATE = template0 ENCODING = 'UTF8';


ALTER DATABASE perfmon OWNER TO erik;

\connect perfmon

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 1669 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pgsql
--

COMMENT ON SCHEMA public IS 'Standard public schema';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1291 (class 1259 OID 16440)
-- Dependencies: 4
-- Name: app; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE app (
    name character varying(64) NOT NULL,
    revision character varying(32) NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.app OWNER TO perfmon;

--
-- TOC entry 1671 (class 0 OID 0)
-- Dependencies: 1291
-- Name: TABLE app; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON TABLE app IS 'A list of applications used by benchmarks. Each name+revision is unique.';


--
-- TOC entry 1292 (class 1259 OID 16449)
-- Dependencies: 4
-- Name: app_conf; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE app_conf (
    id integer NOT NULL,
    param character varying(64) NOT NULL,
    value character varying(256) NOT NULL,
    filename character varying(64) NOT NULL
);


ALTER TABLE public.app_conf OWNER TO perfmon;

--
-- TOC entry 1672 (class 0 OID 0)
-- Dependencies: 1292
-- Name: TABLE app_conf; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON TABLE app_conf IS 'Defines sets of application configuration parameters. Each id may refer to multiple param/value pairs.';


--
-- TOC entry 1293 (class 1259 OID 16465)
-- Dependencies: 4
-- Name: app_group; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE app_group (
    id integer NOT NULL,
    app_id integer NOT NULL,
    app_conf_id integer NOT NULL
);


ALTER TABLE public.app_group OWNER TO perfmon;

--
-- TOC entry 1673 (class 0 OID 0)
-- Dependencies: 1293
-- Name: TABLE app_group; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON TABLE app_group IS 'Defines a collection of applications, i.e. the applications a benchmark depends on to run.';


--
-- TOC entry 1298 (class 1259 OID 16572)
-- Dependencies: 1291 4
-- Name: app_id_seq; Type: SEQUENCE; Schema: public; Owner: perfmon
--

CREATE SEQUENCE app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.app_id_seq OWNER TO perfmon;

--
-- TOC entry 1674 (class 0 OID 0)
-- Dependencies: 1298
-- Name: app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: perfmon
--

ALTER SEQUENCE app_id_seq OWNED BY app.id;


--
-- TOC entry 1289 (class 1259 OID 16428)
-- Dependencies: 4
-- Name: bench; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE bench (
    name character varying(64) NOT NULL,
    revision character varying(32) NOT NULL,
    test_name character varying(64) NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.bench OWNER TO perfmon;

--
-- TOC entry 1675 (class 0 OID 0)
-- Dependencies: 1289
-- Name: TABLE bench; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON TABLE bench IS 'A list of benchmark programs. Each id refers to a unique benchmark/revision/test combination. A test is a single benchmark in a benchmark suite.';


--
-- TOC entry 1676 (class 0 OID 0)
-- Dependencies: 1289
-- Name: COLUMN bench.test_name; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON COLUMN bench.test_name IS 'Benchmarks might run multiple tests. This is the name for a specific test';


--
-- TOC entry 1290 (class 1259 OID 16434)
-- Dependencies: 1635 4
-- Name: bench_conf; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE bench_conf (
    id smallint NOT NULL,
    param character varying(64) NOT NULL,
    unit character varying(10) DEFAULT 'none'::character varying NOT NULL,
    value character varying(256) NOT NULL
);


ALTER TABLE public.bench_conf OWNER TO perfmon;

--
-- TOC entry 1297 (class 1259 OID 16563)
-- Dependencies: 4 1289
-- Name: bench_id_seq; Type: SEQUENCE; Schema: public; Owner: perfmon
--

CREATE SEQUENCE bench_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.bench_id_seq OWNER TO perfmon;

--
-- TOC entry 1677 (class 0 OID 0)
-- Dependencies: 1297
-- Name: bench_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: perfmon
--

ALTER SEQUENCE bench_id_seq OWNED BY bench.id;


--
-- TOC entry 1299 (class 1259 OID 21409)
-- Dependencies: 1637 4
-- Name: cvs_log; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE cvs_log (
    date timestamp without time zone NOT NULL,
    committer character varying(32) NOT NULL,
    filename character varying(100) NOT NULL,
    branch character varying(32) DEFAULT 'HEAD'::character varying NOT NULL,
    revision character varying(32) NOT NULL,
    builds boolean,
    comment text
);


ALTER TABLE public.cvs_log OWNER TO perfmon;

--
-- TOC entry 1678 (class 0 OID 0)
-- Dependencies: 1299
-- Name: TABLE cvs_log; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON TABLE cvs_log IS 'Stores information on who committed which files to the CVS repo and when.';


--
-- TOC entry 1679 (class 0 OID 0)
-- Dependencies: 1299
-- Name: COLUMN cvs_log.date; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON COLUMN cvs_log.date IS 'CVS commit datetime in UTC';


--
-- TOC entry 1680 (class 0 OID 0)
-- Dependencies: 1299
-- Name: COLUMN cvs_log.committer; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON COLUMN cvs_log.committer IS 'FreeBSD committer''s login';


--
-- TOC entry 1681 (class 0 OID 0)
-- Dependencies: 1299
-- Name: COLUMN cvs_log.filename; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON COLUMN cvs_log.filename IS 'Path to modified file';


--
-- TOC entry 1284 (class 1259 OID 16392)
-- Dependencies: 4
-- Name: fact; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE fact (
    machine_id smallint NOT NULL,
    machine_conf_id smallint NOT NULL,
    os_id integer NOT NULL,
    os_conf_id smallint NOT NULL,
    bench_id smallint NOT NULL,
    bench_conf_id smallint NOT NULL,
    x double precision NOT NULL,
    dx_pos real,
    dx_neg real,
    unit character varying(10) NOT NULL,
    comments text,
    id integer NOT NULL,
    app_group_id smallint
);


ALTER TABLE public.fact OWNER TO perfmon;

--
-- TOC entry 1295 (class 1259 OID 16541)
-- Dependencies: 1284 4
-- Name: fact_id_seq; Type: SEQUENCE; Schema: public; Owner: perfmon
--

CREATE SEQUENCE fact_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.fact_id_seq OWNER TO perfmon;

--
-- TOC entry 1682 (class 0 OID 0)
-- Dependencies: 1295
-- Name: fact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: perfmon
--

ALTER SEQUENCE fact_id_seq OWNED BY fact.id;


--
-- TOC entry 1285 (class 1259 OID 16400)
-- Dependencies: 4
-- Name: machine; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE machine (
    ip_addr inet,
    name character varying(64) NOT NULL,
    hostname character varying(256),
    contact character varying(256) NOT NULL,
    contact_email character varying(256),
    comment text,
    id integer NOT NULL
);


ALTER TABLE public.machine OWNER TO perfmon;

--
-- TOC entry 1683 (class 0 OID 0)
-- Dependencies: 1285
-- Name: COLUMN machine.name; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON COLUMN machine.name IS 'Machine name';


--
-- TOC entry 1684 (class 0 OID 0)
-- Dependencies: 1285
-- Name: COLUMN machine.hostname; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON COLUMN machine.hostname IS 'DNS hostname';


--
-- TOC entry 1286 (class 1259 OID 16411)
-- Dependencies: 1632 4
-- Name: machine_conf; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE machine_conf (
    id smallint NOT NULL,
    param character varying(64) NOT NULL,
    value character varying(256) NOT NULL,
    unit character varying(10) DEFAULT 'none'::character varying NOT NULL
);


ALTER TABLE public.machine_conf OWNER TO perfmon;

--
-- TOC entry 1296 (class 1259 OID 16552)
-- Dependencies: 1285 4
-- Name: machine_id_seq; Type: SEQUENCE; Schema: public; Owner: perfmon
--

CREATE SEQUENCE machine_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.machine_id_seq OWNER TO perfmon;

--
-- TOC entry 1685 (class 0 OID 0)
-- Dependencies: 1296
-- Name: machine_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: perfmon
--

ALTER SEQUENCE machine_id_seq OWNED BY machine.id;


--
-- TOC entry 1287 (class 1259 OID 16417)
-- Dependencies: 4
-- Name: os; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE os (
    name character varying(64) NOT NULL,
    branch character varying(64) NOT NULL,
    cvs_date_utc timestamp without time zone NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.os OWNER TO perfmon;

--
-- TOC entry 1686 (class 0 OID 0)
-- Dependencies: 1287
-- Name: COLUMN os.branch; Type: COMMENT; Schema: public; Owner: perfmon
--

COMMENT ON COLUMN os.branch IS 'CVS branch or tag';


--
-- TOC entry 1288 (class 1259 OID 16424)
-- Dependencies: 4
-- Name: os_conf; Type: TABLE; Schema: public; Owner: perfmon; Tablespace: 
--

CREATE TABLE os_conf (
    param character varying(64) NOT NULL,
    value character varying(256) NOT NULL,
    filename character varying(64) NOT NULL,
    id smallint NOT NULL
);


ALTER TABLE public.os_conf OWNER TO perfmon;

--
-- TOC entry 1294 (class 1259 OID 16528)
-- Dependencies: 4 1287
-- Name: os_id_seq; Type: SEQUENCE; Schema: public; Owner: perfmon
--

CREATE SEQUENCE os_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.os_id_seq OWNER TO perfmon;

--
-- TOC entry 1687 (class 0 OID 0)
-- Dependencies: 1294
-- Name: os_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: perfmon
--

ALTER SEQUENCE os_id_seq OWNED BY os.id;


--
-- TOC entry 1636 (class 2604 OID 16574)
-- Dependencies: 1298 1291
-- Name: id; Type: DEFAULT; Schema: public; Owner: perfmon
--

ALTER TABLE app ALTER COLUMN id SET DEFAULT nextval('app_id_seq'::regclass);


--
-- TOC entry 1634 (class 2604 OID 16565)
-- Dependencies: 1297 1289
-- Name: id; Type: DEFAULT; Schema: public; Owner: perfmon
--

ALTER TABLE bench ALTER COLUMN id SET DEFAULT nextval('bench_id_seq'::regclass);


--
-- TOC entry 1630 (class 2604 OID 16543)
-- Dependencies: 1295 1284
-- Name: id; Type: DEFAULT; Schema: public; Owner: perfmon
--

ALTER TABLE fact ALTER COLUMN id SET DEFAULT nextval('fact_id_seq'::regclass);


--
-- TOC entry 1631 (class 2604 OID 16554)
-- Dependencies: 1296 1285
-- Name: id; Type: DEFAULT; Schema: public; Owner: perfmon
--

ALTER TABLE machine ALTER COLUMN id SET DEFAULT nextval('machine_id_seq'::regclass);


--
-- TOC entry 1633 (class 2604 OID 16530)
-- Dependencies: 1294 1287
-- Name: id; Type: DEFAULT; Schema: public; Owner: perfmon
--

ALTER TABLE os ALTER COLUMN id SET DEFAULT nextval('os_id_seq'::regclass);


--
-- TOC entry 1661 (class 2606 OID 16519)
-- Dependencies: 1292 1292 1292 1292 1292
-- Name: app_conf_id; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY app_conf
    ADD CONSTRAINT app_conf_id PRIMARY KEY (id, param, value, filename);


--
-- TOC entry 1663 (class 2606 OID 21531)
-- Dependencies: 1293 1293 1293
-- Name: app_group_pkey; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY app_group
    ADD CONSTRAINT app_group_pkey PRIMARY KEY (id, app_id);


--
-- TOC entry 1657 (class 2606 OID 16580)
-- Dependencies: 1291 1291
-- Name: app_pkey; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY app
    ADD CONSTRAINT app_pkey PRIMARY KEY (id);


--
-- TOC entry 1659 (class 2606 OID 16446)
-- Dependencies: 1291 1291 1291
-- Name: app_rev; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY app
    ADD CONSTRAINT app_rev UNIQUE (name, revision);


--
-- TOC entry 1655 (class 2606 OID 16592)
-- Dependencies: 1290 1290 1290 1290 1290
-- Name: bench_conf_pkey; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY bench_conf
    ADD CONSTRAINT bench_conf_pkey PRIMARY KEY (id, param, unit, value);


--
-- TOC entry 1651 (class 2606 OID 16571)
-- Dependencies: 1289 1289
-- Name: bench_pkey; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY bench
    ADD CONSTRAINT bench_pkey PRIMARY KEY (id);


--
-- TOC entry 1653 (class 2606 OID 16433)
-- Dependencies: 1289 1289 1289 1289
-- Name: bench_rev_id; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY bench
    ADD CONSTRAINT bench_rev_id UNIQUE (name, revision, test_name);


--
-- TOC entry 1665 (class 2606 OID 21426)
-- Dependencies: 1299 1299 1299 1299 1299 1299
-- Name: cvs_log_pkey; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY cvs_log
    ADD CONSTRAINT cvs_log_pkey PRIMARY KEY (date, committer, filename, branch, revision);


--
-- TOC entry 1639 (class 2606 OID 16551)
-- Dependencies: 1284 1284
-- Name: fact_pkey; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY fact
    ADD CONSTRAINT fact_pkey PRIMARY KEY (id);


--
-- TOC entry 1643 (class 2606 OID 16596)
-- Dependencies: 1286 1286 1286 1286 1286
-- Name: machine_conf_pkey; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY machine_conf
    ADD CONSTRAINT machine_conf_pkey PRIMARY KEY (id, param, value, unit);


--
-- TOC entry 1641 (class 2606 OID 16562)
-- Dependencies: 1285 1285
-- Name: machine_pkey; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY machine
    ADD CONSTRAINT machine_pkey PRIMARY KEY (id);


--
-- TOC entry 1649 (class 2606 OID 16540)
-- Dependencies: 1288 1288 1288 1288 1288
-- Name: os_conf_pkey; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY os_conf
    ADD CONSTRAINT os_conf_pkey PRIMARY KEY (param, value, filename, id);


--
-- TOC entry 1645 (class 2606 OID 16598)
-- Dependencies: 1287 1287
-- Name: os_pkey; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY os
    ADD CONSTRAINT os_pkey PRIMARY KEY (id);


--
-- TOC entry 1647 (class 2606 OID 16423)
-- Dependencies: 1287 1287 1287 1287
-- Name: os_rev; Type: CONSTRAINT; Schema: public; Owner: perfmon; Tablespace: 
--

ALTER TABLE ONLY os
    ADD CONSTRAINT os_rev UNIQUE (name, branch, cvs_date_utc);


--
-- TOC entry 1670 (class 0 OID 0)
-- Dependencies: 4
-- Name: public; Type: ACL; Schema: -; Owner: pgsql
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM pgsql;
GRANT ALL ON SCHEMA public TO pgsql;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2008-01-23 14:29:30 CET

--
-- PostgreSQL database dump complete
--

