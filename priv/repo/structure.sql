--
-- PostgreSQL database dump
--

-- Dumped from database version 16.0
-- Dumped by pg_dump version 16.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id character varying(255) NOT NULL,
    ledger_id character varying(48) NOT NULL,
    balance integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: accounts_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts_transactions (
    account_id character varying(255) NOT NULL,
    transaction_id uuid NOT NULL,
    delta_amount integer NOT NULL,
    balance_after integer NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: accounts_transactions accounts_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_transactions
    ADD CONSTRAINT accounts_transactions_pkey PRIMARY KEY (account_id, transaction_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: accounts_ledger_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_ledger_id_index ON public.accounts USING btree (ledger_id);


--
-- Name: accounts_transactions_account_id_transaction_id_DESC_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "accounts_transactions_account_id_transaction_id_DESC_index" ON public.accounts_transactions USING btree (account_id, transaction_id DESC);


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20231028161536);
