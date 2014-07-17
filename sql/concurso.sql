--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agente; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE agente (
    codigo integer,
    cidade integer,
    nome character varying,
    resp integer
);


ALTER TABLE public.agente OWNER TO postgres;

--
-- Name: aposta; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE aposta (
    aposta integer,
    agente integer,
    data timestamp without time zone,
    concurso integer
);


ALTER TABLE public.aposta OWNER TO postgres;

--
-- Name: aposta_numeros; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE aposta_numeros (
    aposta integer,
    numero integer
);


ALTER TABLE public.aposta_numeros OWNER TO postgres;

--
-- Name: cidades; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cidades (
    codigo integer,
    nome character varying,
    uf character(2)
);


ALTER TABLE public.cidades OWNER TO postgres;

--
-- Name: concurso; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE concurso (
    numero integer,
    data date,
    arrecadacao numeric(20,2),
    premio1 numeric(20,2),
    premio2 numeric(20,2),
    acertadores1 integer,
    acertadores2 integer
);


ALTER TABLE public.concurso OWNER TO postgres;

--
-- Name: concurso_numeros; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE concurso_numeros (
    concurso integer,
    numero integer
);


ALTER TABLE public.concurso_numeros OWNER TO postgres;

--
-- Name: estados; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE estados (
    uf character(2),
    nome character varying(20)
);


ALTER TABLE public.estados OWNER TO postgres;

--
-- Data for Name: agente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY agente (codigo, cidade, nome, resp) FROM stdin;
1	1	Fulano	\N
2	3	Ciclano	1
3	6	Beltrano	1
4	9	Juliano	10
5	12	Fabiano	7
6	2	Juliana	7
7	4	Matheus	\N
8	6	Patricia	3
9	8	Renata	10
10	10	Vander	3
11	11	Alex	7
12	5	Rosilei	3
13	7	Pires	3
14	10	Renato	\N
15	12	Mara	10
\.


--
-- Data for Name: aposta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY aposta (aposta, agente, data, concurso) FROM stdin;
1	7	2006-06-27 11:00:00	1
2	4	2006-06-27 11:10:00	1
3	3	2006-06-27 11:15:00	1
4	6	2006-06-27 12:30:00	1
5	2	2006-06-27 13:01:00	1
6	1	2006-06-27 13:10:00	1
7	5	2006-06-27 13:31:00	1
8	9	2006-06-27 13:51:00	1
9	8	2006-06-27 14:01:00	1
10	11	2006-06-27 15:01:00	1
11	12	2006-06-27 17:41:00	1
12	10	2006-06-27 17:51:00	1
\.


--
-- Data for Name: aposta_numeros; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY aposta_numeros (aposta, numero) FROM stdin;
1	1
2	3
3	5
4	2
5	4
6	5
7	4
8	3
9	2
10	1
11	1
12	2
13	3
14	4
15	5
16	3
17	5
18	1
19	4
20	2
\.


--
-- Data for Name: cidades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY cidades (codigo, nome, uf) FROM stdin;
1	São Paulo	SP
2	Sorocaba	SP
3	Osasco	SP
4	Campinas	SP
5	Belo Horizonte	MG
6	Ouro Preto	MG
7	Congonhas	MG
8	Balneário Camburiú	SC
9	Florianópolis	SC
10	Blumenau	SC
11	Rio de Janeiro	RJ
12	Angra dos Reis	RJ
\.


--
-- Data for Name: concurso; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY concurso (numero, data, arrecadacao, premio1, premio2, acertadores1, acertadores2) FROM stdin;
1	2008-10-23	100000.00	25000.00	30000.00	4	2
2	2008-10-24	500000.00	25000.00	30000.00	2	\N
3	2008-10-25	600000.00	25000.00	30000.00	1	5
4	2008-11-02	200000.00	25000.00	30000.00	\N	\N
5	2008-11-03	300000.00	25000.00	30000.00	\N	5
6	2008-11-04	400000.00	25000.00	30000.00	8	2
7	2008-11-05	400000.00	25000.00	30000.00	1	2
8	2008-12-15	400000.00	25000.00	30000.00	4	\N
9	2008-12-16	500000.00	25000.00	30000.00	6	2
10	2008-12-17	500000.00	25000.00	30000.00	\N	4
\.


--
-- Data for Name: concurso_numeros; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY concurso_numeros (concurso, numero) FROM stdin;
1	2
2	4
3	6
4	8
5	10
6	1
7	3
8	5
9	7
10	9
11	1
12	2
13	3
14	4
15	5
16	10
17	9
18	8
19	7
20	6
\.


--
-- Data for Name: estados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY estados (uf, nome) FROM stdin;
SP	São Paulo
MG	Minas Gerais
SC	Santa Catarina
RJ	Rio de Janeiro
\.


--
-- Name: public; Type: ACL; Schema: -; Owner: matheus.oliveira
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

