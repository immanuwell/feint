--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

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
-- Name: 2fa_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."2fa_tokens" (
    id integer NOT NULL,
    user_id integer NOT NULL,
    expires_at timestamp(0) without time zone NOT NULL,
    token character varying(64) NOT NULL
);


--
-- Name: 2fa_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."2fa_tokens_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: 2fa_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."2fa_tokens_id_seq" OWNED BY public."2fa_tokens".id;


--
-- Name: account_balances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_balances (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    title character varying(100),
    account_id integer NOT NULL,
    transaction_currency_id integer NOT NULL,
    date date,
    transaction_journal_id integer,
    balance numeric(32,12) NOT NULL,
    date_tz character varying(50)
);


--
-- Name: account_balances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_balances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_balances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_balances_id_seq OWNED BY public.account_balances.id;


--
-- Name: account_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_meta (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    account_id integer NOT NULL,
    name character varying(191) NOT NULL,
    data text NOT NULL
);


--
-- Name: account_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_meta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_meta_id_seq OWNED BY public.account_meta.id;


--
-- Name: account_piggy_bank; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_piggy_bank (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    piggy_bank_id integer NOT NULL,
    current_amount numeric(32,12) DEFAULT '0'::numeric NOT NULL,
    native_current_amount numeric(32,12)
);


--
-- Name: account_piggy_bank_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_piggy_bank_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_piggy_bank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_piggy_bank_id_seq OWNED BY public.account_piggy_bank.id;


--
-- Name: account_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_types (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    type character varying(50) NOT NULL
);


--
-- Name: account_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_types_id_seq OWNED BY public.account_types.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    account_type_id integer NOT NULL,
    name character varying(1024) NOT NULL,
    virtual_balance numeric(32,12),
    iban character varying(255),
    active boolean DEFAULT true NOT NULL,
    encrypted boolean DEFAULT false NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    user_group_id bigint,
    native_virtual_balance numeric(32,12)
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachments (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    attachable_id integer NOT NULL,
    attachable_type character varying(255) NOT NULL,
    md5 character varying(128) NOT NULL,
    filename character varying(1024) NOT NULL,
    title character varying(1024),
    description text,
    mime character varying(1024) NOT NULL,
    size integer NOT NULL,
    uploaded boolean DEFAULT true NOT NULL,
    user_group_id bigint
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attachments_id_seq OWNED BY public.attachments.id;


--
-- Name: audit_log_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_log_entries (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    auditable_id integer NOT NULL,
    auditable_type character varying(191) NOT NULL,
    changer_id integer NOT NULL,
    changer_type character varying(191) NOT NULL,
    action character varying(255) NOT NULL,
    before text,
    after text
);


--
-- Name: audit_log_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_log_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_log_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_log_entries_id_seq OWNED BY public.audit_log_entries.id;


--
-- Name: auto_budgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auto_budgets (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    budget_id integer NOT NULL,
    transaction_currency_id integer NOT NULL,
    auto_budget_type smallint DEFAULT '1'::smallint NOT NULL,
    amount numeric(32,12) NOT NULL,
    period character varying(50) NOT NULL,
    native_amount numeric(32,12)
);


--
-- Name: auto_budgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auto_budgets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auto_budgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auto_budgets_id_seq OWNED BY public.auto_budgets.id;


--
-- Name: available_budgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.available_budgets (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    transaction_currency_id integer NOT NULL,
    amount numeric(32,12) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    user_group_id bigint,
    start_date_tz character varying(50),
    end_date_tz character varying(50),
    native_amount numeric(32,12)
);


--
-- Name: available_budgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.available_budgets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: available_budgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.available_budgets_id_seq OWNED BY public.available_budgets.id;


--
-- Name: bills; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bills (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    name character varying(1024) NOT NULL,
    match character varying(1024) NOT NULL,
    amount_min numeric(32,12) NOT NULL,
    amount_max numeric(32,12) NOT NULL,
    date date NOT NULL,
    repeat_freq character varying(30) NOT NULL,
    skip smallint DEFAULT '0'::smallint NOT NULL,
    automatch boolean DEFAULT true NOT NULL,
    active boolean DEFAULT true NOT NULL,
    name_encrypted boolean DEFAULT false NOT NULL,
    match_encrypted boolean DEFAULT false NOT NULL,
    transaction_currency_id integer,
    "order" integer DEFAULT 0 NOT NULL,
    end_date date,
    extension_date date,
    user_group_id bigint,
    date_tz character varying(50),
    end_date_tz character varying(50),
    extension_date_tz character varying(50),
    native_amount_min numeric(32,12),
    native_amount_max numeric(32,12)
);


--
-- Name: bills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bills_id_seq OWNED BY public.bills.id;


--
-- Name: budget_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budget_limits (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    budget_id integer NOT NULL,
    start_date date NOT NULL,
    amount numeric(32,12) NOT NULL,
    end_date date,
    transaction_currency_id integer,
    period character varying(12),
    generated boolean DEFAULT false NOT NULL,
    start_date_tz character varying(50),
    end_date_tz character varying(50),
    native_amount numeric(32,12)
);


--
-- Name: budget_limits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.budget_limits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: budget_limits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.budget_limits_id_seq OWNED BY public.budget_limits.id;


--
-- Name: budget_transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budget_transaction (
    id integer NOT NULL,
    budget_id integer NOT NULL,
    transaction_id integer NOT NULL
);


--
-- Name: budget_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.budget_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: budget_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.budget_transaction_id_seq OWNED BY public.budget_transaction.id;


--
-- Name: budget_transaction_journal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budget_transaction_journal (
    id integer NOT NULL,
    budget_id integer NOT NULL,
    transaction_journal_id integer NOT NULL,
    budget_limit_id integer
);


--
-- Name: budget_transaction_journal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.budget_transaction_journal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: budget_transaction_journal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.budget_transaction_journal_id_seq OWNED BY public.budget_transaction_journal.id;


--
-- Name: budgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budgets (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    name character varying(1024) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    encrypted boolean DEFAULT false NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    user_group_id bigint
);


--
-- Name: budgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.budgets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: budgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.budgets_id_seq OWNED BY public.budgets.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    name character varying(1024) NOT NULL,
    encrypted boolean DEFAULT false NOT NULL,
    user_group_id bigint
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: category_transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_transaction (
    id integer NOT NULL,
    category_id integer NOT NULL,
    transaction_id integer NOT NULL
);


--
-- Name: category_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.category_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: category_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.category_transaction_id_seq OWNED BY public.category_transaction.id;


--
-- Name: category_transaction_journal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_transaction_journal (
    id integer NOT NULL,
    category_id integer NOT NULL,
    transaction_journal_id integer NOT NULL
);


--
-- Name: category_transaction_journal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.category_transaction_journal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: category_transaction_journal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.category_transaction_journal_id_seq OWNED BY public.category_transaction_journal.id;


--
-- Name: configuration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuration (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    name character varying(50) NOT NULL,
    data text NOT NULL
);


--
-- Name: configuration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.configuration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configuration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.configuration_id_seq OWNED BY public.configuration.id;


--
-- Name: currency_exchange_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currency_exchange_rates (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    from_currency_id integer NOT NULL,
    to_currency_id integer NOT NULL,
    date date NOT NULL,
    rate numeric(32,12) NOT NULL,
    user_rate numeric(32,12),
    user_group_id bigint,
    date_tz character varying(50)
);


--
-- Name: currency_exchange_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.currency_exchange_rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: currency_exchange_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.currency_exchange_rates_id_seq OWNED BY public.currency_exchange_rates.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(191) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: group_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_journals (
    id integer NOT NULL,
    transaction_group_id integer NOT NULL,
    transaction_journal_id integer NOT NULL
);


--
-- Name: group_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_journals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_journals_id_seq OWNED BY public.group_journals.id;


--
-- Name: group_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_memberships (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    user_group_id bigint NOT NULL,
    user_role_id bigint NOT NULL
);


--
-- Name: group_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_memberships_id_seq OWNED BY public.group_memberships.id;


--
-- Name: invited_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invited_users (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    email character varying(255) NOT NULL,
    invite_code character varying(64) NOT NULL,
    expires timestamp(0) without time zone NOT NULL,
    redeemed boolean NOT NULL,
    expires_tz character varying(50)
);


--
-- Name: invited_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invited_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invited_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invited_users_id_seq OWNED BY public.invited_users.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(191) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: journal_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journal_links (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    link_type_id integer NOT NULL,
    source_id integer NOT NULL,
    destination_id integer NOT NULL,
    comment text
);


--
-- Name: journal_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.journal_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journal_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.journal_links_id_seq OWNED BY public.journal_links.id;


--
-- Name: journal_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journal_meta (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    transaction_journal_id integer NOT NULL,
    name character varying(255) NOT NULL,
    data text NOT NULL,
    hash character varying(64) NOT NULL,
    deleted_at timestamp(0) without time zone
);


--
-- Name: journal_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.journal_meta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journal_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.journal_meta_id_seq OWNED BY public.journal_meta.id;


--
-- Name: link_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link_types (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    name character varying(191) NOT NULL,
    outward character varying(191) NOT NULL,
    inward character varying(191) NOT NULL,
    editable boolean NOT NULL
);


--
-- Name: link_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.link_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.link_types_id_seq OWNED BY public.link_types.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    locatable_id integer NOT NULL,
    locatable_type character varying(255) NOT NULL,
    latitude numeric(12,8),
    longitude numeric(12,8),
    zoom_level smallint
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(191) NOT NULL,
    batch integer NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    noteable_id integer NOT NULL,
    noteable_type character varying(191) NOT NULL,
    title character varying(191),
    text text
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid NOT NULL,
    type character varying(191) NOT NULL,
    notifiable_type character varying(191) NOT NULL,
    notifiable_id bigint NOT NULL,
    data text NOT NULL,
    read_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id character(80) NOT NULL,
    user_id bigint,
    client_id uuid NOT NULL,
    name character varying(191),
    scopes text,
    revoked boolean NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone
);


--
-- Name: oauth_auth_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_auth_codes (
    id character(80) NOT NULL,
    user_id bigint NOT NULL,
    client_id uuid NOT NULL,
    scopes text,
    revoked boolean NOT NULL,
    expires_at timestamp(0) without time zone
);


--
-- Name: oauth_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_clients (
    id uuid NOT NULL,
    owner_type character varying(191),
    owner_id bigint,
    name character varying(191) NOT NULL,
    secret character varying(191),
    provider character varying(191),
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    revoked boolean NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: oauth_device_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_device_codes (
    id character(80) NOT NULL,
    user_id bigint,
    client_id uuid NOT NULL,
    user_code character(8) NOT NULL,
    scopes text NOT NULL,
    revoked boolean NOT NULL,
    user_approved_at timestamp(0) without time zone,
    last_polled_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone
);


--
-- Name: oauth_refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_refresh_tokens (
    id character(80) NOT NULL,
    access_token_id character(80) NOT NULL,
    revoked boolean NOT NULL,
    expires_at timestamp(0) without time zone
);


--
-- Name: object_groupables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.object_groupables (
    object_group_id integer NOT NULL,
    object_groupable_id integer NOT NULL,
    object_groupable_type character varying(255) NOT NULL
);


--
-- Name: object_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.object_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    title character varying(255) NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    user_group_id bigint
);


--
-- Name: object_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.object_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: object_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.object_groups_id_seq OWNED BY public.object_groups.id;


--
-- Name: password_resets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_resets (
    email character varying(191) NOT NULL,
    token character varying(191) NOT NULL,
    created_at timestamp(0) without time zone
);


--
-- Name: period_statistics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.period_statistics (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    user_group_id bigint NOT NULL,
    primary_statable_id integer,
    primary_statable_type character varying(255),
    secondary_statable_id integer,
    secondary_statable_type character varying(255),
    tertiary_statable_id integer,
    tertiary_statable_type character varying(255),
    transaction_currency_id integer NOT NULL,
    start timestamp(0) without time zone,
    start_tz character varying(50),
    "end" timestamp(0) without time zone,
    end_tz character varying(50),
    type character varying(255) NOT NULL,
    count integer DEFAULT 0 NOT NULL,
    amount numeric(32,12) NOT NULL
);


--
-- Name: period_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.period_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: period_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.period_statistics_id_seq OWNED BY public.period_statistics.id;


--
-- Name: permission_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permission_role (
    permission_id integer NOT NULL,
    role_id integer NOT NULL
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    name character varying(191) NOT NULL,
    display_name character varying(191),
    description character varying(191)
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(191) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: piggy_bank_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.piggy_bank_events (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    piggy_bank_id integer NOT NULL,
    transaction_journal_id integer,
    date date NOT NULL,
    amount numeric(32,12) NOT NULL,
    date_tz character varying(50),
    native_amount numeric(32,12)
);


--
-- Name: piggy_bank_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.piggy_bank_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: piggy_bank_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.piggy_bank_events_id_seq OWNED BY public.piggy_bank_events.id;


--
-- Name: piggy_bank_repetitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.piggy_bank_repetitions (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    piggy_bank_id integer NOT NULL,
    start_date date,
    target_date date,
    current_amount numeric(32,12) NOT NULL,
    start_date_tz character varying(50),
    target_date_tz character varying(50)
);


--
-- Name: piggy_bank_repetitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.piggy_bank_repetitions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: piggy_bank_repetitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.piggy_bank_repetitions_id_seq OWNED BY public.piggy_bank_repetitions.id;


--
-- Name: piggy_banks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.piggy_banks (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    account_id integer,
    name character varying(1024) NOT NULL,
    target_amount numeric(32,12) NOT NULL,
    start_date date,
    target_date date,
    "order" integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT false NOT NULL,
    encrypted boolean DEFAULT true NOT NULL,
    start_date_tz character varying(50),
    target_date_tz character varying(50),
    transaction_currency_id integer,
    native_target_amount numeric(32,12)
);


--
-- Name: piggy_banks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.piggy_banks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: piggy_banks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.piggy_banks_id_seq OWNED BY public.piggy_banks.id;


--
-- Name: preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preferences (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    name character varying(1024) NOT NULL,
    data text,
    user_group_id bigint
);


--
-- Name: preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.preferences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.preferences_id_seq OWNED BY public.preferences.id;


--
-- Name: recurrences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurrences (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    transaction_type_id integer NOT NULL,
    title character varying(1024) NOT NULL,
    description text NOT NULL,
    first_date date NOT NULL,
    repeat_until date,
    latest_date date,
    repetitions smallint NOT NULL,
    apply_rules boolean DEFAULT true NOT NULL,
    active boolean DEFAULT true NOT NULL,
    user_group_id bigint,
    first_date_tz character varying(50),
    repeat_until_tz character varying(50),
    latest_date_tz character varying(50)
);


--
-- Name: recurrences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recurrences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurrences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recurrences_id_seq OWNED BY public.recurrences.id;


--
-- Name: recurrences_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurrences_meta (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    recurrence_id integer NOT NULL,
    name character varying(50) NOT NULL,
    value text NOT NULL
);


--
-- Name: recurrences_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recurrences_meta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurrences_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recurrences_meta_id_seq OWNED BY public.recurrences_meta.id;


--
-- Name: recurrences_repetitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurrences_repetitions (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    recurrence_id integer NOT NULL,
    repetition_type character varying(50) NOT NULL,
    repetition_moment character varying(50) NOT NULL,
    repetition_skip smallint NOT NULL,
    weekend smallint NOT NULL
);


--
-- Name: recurrences_repetitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recurrences_repetitions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurrences_repetitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recurrences_repetitions_id_seq OWNED BY public.recurrences_repetitions.id;


--
-- Name: recurrences_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurrences_transactions (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    recurrence_id integer NOT NULL,
    transaction_currency_id integer NOT NULL,
    foreign_currency_id integer,
    source_id integer NOT NULL,
    destination_id integer NOT NULL,
    amount numeric(32,12) NOT NULL,
    foreign_amount numeric(32,12),
    description character varying(1024) NOT NULL,
    transaction_type_id integer
);


--
-- Name: recurrences_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recurrences_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurrences_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recurrences_transactions_id_seq OWNED BY public.recurrences_transactions.id;


--
-- Name: role_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_user (
    user_id integer NOT NULL,
    role_id integer NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    name character varying(191) NOT NULL,
    display_name character varying(191),
    description character varying(191)
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: rt_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rt_meta (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    rt_id integer NOT NULL,
    name character varying(50) NOT NULL,
    value text NOT NULL
);


--
-- Name: rt_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rt_meta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rt_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rt_meta_id_seq OWNED BY public.rt_meta.id;


--
-- Name: rule_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rule_actions (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    rule_id integer NOT NULL,
    action_type character varying(50) NOT NULL,
    action_value character varying(255) NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    stop_processing boolean DEFAULT false NOT NULL
);


--
-- Name: rule_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rule_actions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rule_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rule_actions_id_seq OWNED BY public.rule_actions.id;


--
-- Name: rule_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rule_groups (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    "order" integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    stop_processing boolean DEFAULT false NOT NULL,
    user_group_id bigint
);


--
-- Name: rule_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rule_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rule_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rule_groups_id_seq OWNED BY public.rule_groups.id;


--
-- Name: rule_triggers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rule_triggers (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    rule_id integer NOT NULL,
    trigger_type character varying(50) NOT NULL,
    trigger_value character varying(255) NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    stop_processing boolean DEFAULT false NOT NULL
);


--
-- Name: rule_triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rule_triggers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rule_triggers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rule_triggers_id_seq OWNED BY public.rule_triggers.id;


--
-- Name: rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rules (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    rule_group_id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    "order" integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    stop_processing boolean DEFAULT false NOT NULL,
    strict boolean DEFAULT true NOT NULL,
    user_group_id bigint
);


--
-- Name: rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rules_id_seq OWNED BY public.rules.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(191) NOT NULL,
    user_id integer,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


--
-- Name: tag_transaction_journal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_transaction_journal (
    id integer NOT NULL,
    tag_id integer NOT NULL,
    transaction_journal_id integer NOT NULL
);


--
-- Name: tag_transaction_journal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_transaction_journal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_transaction_journal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_transaction_journal_id_seq OWNED BY public.tag_transaction_journal.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    tag character varying(1024) NOT NULL,
    tag_mode character varying(1024) NOT NULL,
    date date,
    description text,
    latitude numeric(12,8),
    longitude numeric(12,8),
    "zoomLevel" smallint,
    user_group_id bigint,
    date_tz character varying(50)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: transaction_currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_currencies (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    code character varying(51) NOT NULL,
    name character varying(255) NOT NULL,
    symbol character varying(51) NOT NULL,
    decimal_places smallint DEFAULT '2'::smallint NOT NULL,
    enabled boolean DEFAULT false NOT NULL
);


--
-- Name: transaction_currencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_currencies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_currencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_currencies_id_seq OWNED BY public.transaction_currencies.id;


--
-- Name: transaction_currency_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_currency_user (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    transaction_currency_id integer NOT NULL,
    user_default boolean DEFAULT false NOT NULL
);


--
-- Name: transaction_currency_user_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_currency_user_group (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    user_group_id bigint NOT NULL,
    transaction_currency_id integer NOT NULL,
    group_default boolean DEFAULT false NOT NULL
);


--
-- Name: transaction_currency_user_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_currency_user_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_currency_user_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_currency_user_group_id_seq OWNED BY public.transaction_currency_user_group.id;


--
-- Name: transaction_currency_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_currency_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_currency_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_currency_user_id_seq OWNED BY public.transaction_currency_user.id;


--
-- Name: transaction_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_groups (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    title character varying(1024),
    user_group_id bigint
);


--
-- Name: transaction_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_groups_id_seq OWNED BY public.transaction_groups.id;


--
-- Name: transaction_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_journals (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    transaction_type_id integer NOT NULL,
    bill_id integer,
    transaction_currency_id integer,
    description character varying(1024) NOT NULL,
    date timestamp(0) without time zone NOT NULL,
    interest_date date,
    book_date date,
    process_date date,
    "order" integer DEFAULT 0 NOT NULL,
    tag_count integer NOT NULL,
    encrypted boolean DEFAULT true NOT NULL,
    completed boolean DEFAULT true NOT NULL,
    transaction_group_id integer,
    user_group_id bigint,
    date_tz character varying(50)
);


--
-- Name: transaction_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_journals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_journals_id_seq OWNED BY public.transaction_journals.id;


--
-- Name: transaction_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_types (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    type character varying(50) NOT NULL
);


--
-- Name: transaction_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_types_id_seq OWNED BY public.transaction_types.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    account_id integer NOT NULL,
    transaction_journal_id integer NOT NULL,
    description character varying(1024),
    amount numeric(32,12) NOT NULL,
    identifier smallint DEFAULT '0'::smallint NOT NULL,
    transaction_currency_id integer,
    foreign_amount numeric(32,12),
    foreign_currency_id integer,
    reconciled boolean DEFAULT false NOT NULL,
    balance_before numeric(32,12),
    balance_after numeric(32,12),
    balance_dirty boolean DEFAULT true NOT NULL,
    native_amount numeric(32,12),
    native_foreign_amount numeric(32,12)
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_groups (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    title character varying(255) NOT NULL
);


--
-- Name: user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_groups_id_seq OWNED BY public.user_groups.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    title character varying(255) NOT NULL
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    email character varying(255) NOT NULL,
    password character varying(60) NOT NULL,
    remember_token character varying(100),
    reset character varying(32),
    blocked smallint DEFAULT '0'::smallint NOT NULL,
    blocked_code character varying(25),
    objectguid uuid,
    mfa_secret character varying(50),
    domain character varying(191),
    user_group_id bigint
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: webhook_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_attempts (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    webhook_message_id integer NOT NULL,
    status_code smallint DEFAULT '0'::smallint NOT NULL,
    logs text,
    response text
);


--
-- Name: webhook_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhook_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhook_attempts_id_seq OWNED BY public.webhook_attempts.id;


--
-- Name: webhook_deliveries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_deliveries (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    key smallint NOT NULL,
    title character varying(100) NOT NULL
);


--
-- Name: webhook_deliveries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhook_deliveries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_deliveries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhook_deliveries_id_seq OWNED BY public.webhook_deliveries.id;


--
-- Name: webhook_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_messages (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    sent boolean DEFAULT false NOT NULL,
    errored boolean DEFAULT false NOT NULL,
    webhook_id integer NOT NULL,
    uuid character varying(64) NOT NULL,
    message text NOT NULL
);


--
-- Name: webhook_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhook_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhook_messages_id_seq OWNED BY public.webhook_messages.id;


--
-- Name: webhook_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_responses (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    key smallint NOT NULL,
    title character varying(100) NOT NULL
);


--
-- Name: webhook_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhook_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhook_responses_id_seq OWNED BY public.webhook_responses.id;


--
-- Name: webhook_triggers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_triggers (
    id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    key smallint NOT NULL,
    title character varying(100) NOT NULL
);


--
-- Name: webhook_triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhook_triggers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_triggers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhook_triggers_id_seq OWNED BY public.webhook_triggers.id;


--
-- Name: webhook_webhook_delivery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_webhook_delivery (
    id integer NOT NULL,
    webhook_id integer NOT NULL,
    webhook_delivery_id bigint NOT NULL
);


--
-- Name: webhook_webhook_delivery_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhook_webhook_delivery_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_webhook_delivery_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhook_webhook_delivery_id_seq OWNED BY public.webhook_webhook_delivery.id;


--
-- Name: webhook_webhook_response; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_webhook_response (
    id integer NOT NULL,
    webhook_id integer NOT NULL,
    webhook_response_id bigint NOT NULL
);


--
-- Name: webhook_webhook_response_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhook_webhook_response_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_webhook_response_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhook_webhook_response_id_seq OWNED BY public.webhook_webhook_response.id;


--
-- Name: webhook_webhook_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_webhook_trigger (
    id integer NOT NULL,
    webhook_id integer NOT NULL,
    webhook_trigger_id bigint NOT NULL
);


--
-- Name: webhook_webhook_trigger_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhook_webhook_trigger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_webhook_trigger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhook_webhook_trigger_id_seq OWNED BY public.webhook_webhook_trigger.id;


--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks (
    id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    user_id integer NOT NULL,
    title character varying(255) NOT NULL,
    secret character varying(32) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    trigger smallint NOT NULL,
    response smallint NOT NULL,
    delivery smallint NOT NULL,
    url character varying(1024) NOT NULL,
    user_group_id bigint
);


--
-- Name: webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhooks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhooks_id_seq OWNED BY public.webhooks.id;


--
-- Name: 2fa_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2fa_tokens" ALTER COLUMN id SET DEFAULT nextval('public."2fa_tokens_id_seq"'::regclass);


--
-- Name: account_balances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_balances ALTER COLUMN id SET DEFAULT nextval('public.account_balances_id_seq'::regclass);


--
-- Name: account_meta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_meta ALTER COLUMN id SET DEFAULT nextval('public.account_meta_id_seq'::regclass);


--
-- Name: account_piggy_bank id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_piggy_bank ALTER COLUMN id SET DEFAULT nextval('public.account_piggy_bank_id_seq'::regclass);


--
-- Name: account_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_types ALTER COLUMN id SET DEFAULT nextval('public.account_types_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments ALTER COLUMN id SET DEFAULT nextval('public.attachments_id_seq'::regclass);


--
-- Name: audit_log_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log_entries ALTER COLUMN id SET DEFAULT nextval('public.audit_log_entries_id_seq'::regclass);


--
-- Name: auto_budgets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auto_budgets ALTER COLUMN id SET DEFAULT nextval('public.auto_budgets_id_seq'::regclass);


--
-- Name: available_budgets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.available_budgets ALTER COLUMN id SET DEFAULT nextval('public.available_budgets_id_seq'::regclass);


--
-- Name: bills id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bills ALTER COLUMN id SET DEFAULT nextval('public.bills_id_seq'::regclass);


--
-- Name: budget_limits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_limits ALTER COLUMN id SET DEFAULT nextval('public.budget_limits_id_seq'::regclass);


--
-- Name: budget_transaction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_transaction ALTER COLUMN id SET DEFAULT nextval('public.budget_transaction_id_seq'::regclass);


--
-- Name: budget_transaction_journal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_transaction_journal ALTER COLUMN id SET DEFAULT nextval('public.budget_transaction_journal_id_seq'::regclass);


--
-- Name: budgets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets ALTER COLUMN id SET DEFAULT nextval('public.budgets_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: category_transaction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_transaction ALTER COLUMN id SET DEFAULT nextval('public.category_transaction_id_seq'::regclass);


--
-- Name: category_transaction_journal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_transaction_journal ALTER COLUMN id SET DEFAULT nextval('public.category_transaction_journal_id_seq'::regclass);


--
-- Name: configuration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration ALTER COLUMN id SET DEFAULT nextval('public.configuration_id_seq'::regclass);


--
-- Name: currency_exchange_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_exchange_rates ALTER COLUMN id SET DEFAULT nextval('public.currency_exchange_rates_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: group_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_journals ALTER COLUMN id SET DEFAULT nextval('public.group_journals_id_seq'::regclass);


--
-- Name: group_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_memberships ALTER COLUMN id SET DEFAULT nextval('public.group_memberships_id_seq'::regclass);


--
-- Name: invited_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invited_users ALTER COLUMN id SET DEFAULT nextval('public.invited_users_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: journal_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_links ALTER COLUMN id SET DEFAULT nextval('public.journal_links_id_seq'::regclass);


--
-- Name: journal_meta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_meta ALTER COLUMN id SET DEFAULT nextval('public.journal_meta_id_seq'::regclass);


--
-- Name: link_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_types ALTER COLUMN id SET DEFAULT nextval('public.link_types_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: object_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_groups ALTER COLUMN id SET DEFAULT nextval('public.object_groups_id_seq'::regclass);


--
-- Name: period_statistics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.period_statistics ALTER COLUMN id SET DEFAULT nextval('public.period_statistics_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: piggy_bank_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_bank_events ALTER COLUMN id SET DEFAULT nextval('public.piggy_bank_events_id_seq'::regclass);


--
-- Name: piggy_bank_repetitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_bank_repetitions ALTER COLUMN id SET DEFAULT nextval('public.piggy_bank_repetitions_id_seq'::regclass);


--
-- Name: piggy_banks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_banks ALTER COLUMN id SET DEFAULT nextval('public.piggy_banks_id_seq'::regclass);


--
-- Name: preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences ALTER COLUMN id SET DEFAULT nextval('public.preferences_id_seq'::regclass);


--
-- Name: recurrences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences ALTER COLUMN id SET DEFAULT nextval('public.recurrences_id_seq'::regclass);


--
-- Name: recurrences_meta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_meta ALTER COLUMN id SET DEFAULT nextval('public.recurrences_meta_id_seq'::regclass);


--
-- Name: recurrences_repetitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_repetitions ALTER COLUMN id SET DEFAULT nextval('public.recurrences_repetitions_id_seq'::regclass);


--
-- Name: recurrences_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_transactions ALTER COLUMN id SET DEFAULT nextval('public.recurrences_transactions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: rt_meta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rt_meta ALTER COLUMN id SET DEFAULT nextval('public.rt_meta_id_seq'::regclass);


--
-- Name: rule_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_actions ALTER COLUMN id SET DEFAULT nextval('public.rule_actions_id_seq'::regclass);


--
-- Name: rule_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_groups ALTER COLUMN id SET DEFAULT nextval('public.rule_groups_id_seq'::regclass);


--
-- Name: rule_triggers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_triggers ALTER COLUMN id SET DEFAULT nextval('public.rule_triggers_id_seq'::regclass);


--
-- Name: rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules ALTER COLUMN id SET DEFAULT nextval('public.rules_id_seq'::regclass);


--
-- Name: tag_transaction_journal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_transaction_journal ALTER COLUMN id SET DEFAULT nextval('public.tag_transaction_journal_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: transaction_currencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currencies ALTER COLUMN id SET DEFAULT nextval('public.transaction_currencies_id_seq'::regclass);


--
-- Name: transaction_currency_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currency_user ALTER COLUMN id SET DEFAULT nextval('public.transaction_currency_user_id_seq'::regclass);


--
-- Name: transaction_currency_user_group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currency_user_group ALTER COLUMN id SET DEFAULT nextval('public.transaction_currency_user_group_id_seq'::regclass);


--
-- Name: transaction_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_groups ALTER COLUMN id SET DEFAULT nextval('public.transaction_groups_id_seq'::regclass);


--
-- Name: transaction_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_journals ALTER COLUMN id SET DEFAULT nextval('public.transaction_journals_id_seq'::regclass);


--
-- Name: transaction_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_types ALTER COLUMN id SET DEFAULT nextval('public.transaction_types_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: user_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups ALTER COLUMN id SET DEFAULT nextval('public.user_groups_id_seq'::regclass);


--
-- Name: user_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: webhook_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_attempts ALTER COLUMN id SET DEFAULT nextval('public.webhook_attempts_id_seq'::regclass);


--
-- Name: webhook_deliveries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_deliveries ALTER COLUMN id SET DEFAULT nextval('public.webhook_deliveries_id_seq'::regclass);


--
-- Name: webhook_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_messages ALTER COLUMN id SET DEFAULT nextval('public.webhook_messages_id_seq'::regclass);


--
-- Name: webhook_responses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_responses ALTER COLUMN id SET DEFAULT nextval('public.webhook_responses_id_seq'::regclass);


--
-- Name: webhook_triggers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_triggers ALTER COLUMN id SET DEFAULT nextval('public.webhook_triggers_id_seq'::regclass);


--
-- Name: webhook_webhook_delivery id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_delivery ALTER COLUMN id SET DEFAULT nextval('public.webhook_webhook_delivery_id_seq'::regclass);


--
-- Name: webhook_webhook_response id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_response ALTER COLUMN id SET DEFAULT nextval('public.webhook_webhook_response_id_seq'::regclass);


--
-- Name: webhook_webhook_trigger id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_trigger ALTER COLUMN id SET DEFAULT nextval('public.webhook_webhook_trigger_id_seq'::regclass);


--
-- Name: webhooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks ALTER COLUMN id SET DEFAULT nextval('public.webhooks_id_seq'::regclass);


--
-- Name: 2fa_tokens 2fa_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2fa_tokens"
    ADD CONSTRAINT "2fa_tokens_pkey" PRIMARY KEY (id);


--
-- Name: 2fa_tokens 2fa_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2fa_tokens"
    ADD CONSTRAINT "2fa_tokens_token_unique" UNIQUE (token);


--
-- Name: account_balances account_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_balances
    ADD CONSTRAINT account_balances_pkey PRIMARY KEY (id);


--
-- Name: account_meta account_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_meta
    ADD CONSTRAINT account_meta_pkey PRIMARY KEY (id);


--
-- Name: account_piggy_bank account_piggy_bank_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_piggy_bank
    ADD CONSTRAINT account_piggy_bank_pkey PRIMARY KEY (id);


--
-- Name: account_types account_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_types
    ADD CONSTRAINT account_types_pkey PRIMARY KEY (id);


--
-- Name: account_types account_types_type_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_types
    ADD CONSTRAINT account_types_type_unique UNIQUE (type);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: auto_budgets auto_budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auto_budgets
    ADD CONSTRAINT auto_budgets_pkey PRIMARY KEY (id);


--
-- Name: available_budgets available_budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.available_budgets
    ADD CONSTRAINT available_budgets_pkey PRIMARY KEY (id);


--
-- Name: bills bills_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_pkey PRIMARY KEY (id);


--
-- Name: budget_limits budget_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_limits
    ADD CONSTRAINT budget_limits_pkey PRIMARY KEY (id);


--
-- Name: budget_transaction_journal budget_transaction_journal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_transaction_journal
    ADD CONSTRAINT budget_transaction_journal_pkey PRIMARY KEY (id);


--
-- Name: budget_transaction budget_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_transaction
    ADD CONSTRAINT budget_transaction_pkey PRIMARY KEY (id);


--
-- Name: budgets budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: category_transaction_journal category_transaction_journal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_transaction_journal
    ADD CONSTRAINT category_transaction_journal_pkey PRIMARY KEY (id);


--
-- Name: category_transaction category_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_transaction
    ADD CONSTRAINT category_transaction_pkey PRIMARY KEY (id);


--
-- Name: configuration configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT configuration_pkey PRIMARY KEY (id);


--
-- Name: currency_exchange_rates currency_exchange_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_exchange_rates
    ADD CONSTRAINT currency_exchange_rates_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: group_journals group_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_journals
    ADD CONSTRAINT group_journals_pkey PRIMARY KEY (id);


--
-- Name: group_memberships group_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_memberships
    ADD CONSTRAINT group_memberships_pkey PRIMARY KEY (id);


--
-- Name: group_memberships group_memberships_user_id_user_group_id_user_role_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_memberships
    ADD CONSTRAINT group_memberships_user_id_user_group_id_user_role_id_unique UNIQUE (user_id, user_group_id, user_role_id);


--
-- Name: invited_users invited_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invited_users
    ADD CONSTRAINT invited_users_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: journal_links journal_links_link_type_id_source_id_destination_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_links
    ADD CONSTRAINT journal_links_link_type_id_source_id_destination_id_unique UNIQUE (link_type_id, source_id, destination_id);


--
-- Name: journal_links journal_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_links
    ADD CONSTRAINT journal_links_pkey PRIMARY KEY (id);


--
-- Name: journal_meta journal_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_meta
    ADD CONSTRAINT journal_meta_pkey PRIMARY KEY (id);


--
-- Name: link_types link_types_name_outward_inward_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_types
    ADD CONSTRAINT link_types_name_outward_inward_unique UNIQUE (name, outward, inward);


--
-- Name: link_types link_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_types
    ADD CONSTRAINT link_types_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_auth_codes oauth_auth_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_auth_codes
    ADD CONSTRAINT oauth_auth_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_device_codes oauth_device_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_device_codes
    ADD CONSTRAINT oauth_device_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth_device_codes oauth_device_codes_user_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_device_codes
    ADD CONSTRAINT oauth_device_codes_user_code_unique UNIQUE (user_code);


--
-- Name: oauth_refresh_tokens oauth_refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_refresh_tokens
    ADD CONSTRAINT oauth_refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: object_groups object_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_groups
    ADD CONSTRAINT object_groups_pkey PRIMARY KEY (id);


--
-- Name: period_statistics period_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.period_statistics
    ADD CONSTRAINT period_statistics_pkey PRIMARY KEY (id);


--
-- Name: permission_role permission_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_role
    ADD CONSTRAINT permission_role_pkey PRIMARY KEY (permission_id, role_id);


--
-- Name: permissions permissions_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_name_unique UNIQUE (name);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: piggy_bank_events piggy_bank_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_bank_events
    ADD CONSTRAINT piggy_bank_events_pkey PRIMARY KEY (id);


--
-- Name: piggy_bank_repetitions piggy_bank_repetitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_bank_repetitions
    ADD CONSTRAINT piggy_bank_repetitions_pkey PRIMARY KEY (id);


--
-- Name: piggy_banks piggy_banks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_banks
    ADD CONSTRAINT piggy_banks_pkey PRIMARY KEY (id);


--
-- Name: preferences preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (id);


--
-- Name: recurrences_meta recurrences_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_meta
    ADD CONSTRAINT recurrences_meta_pkey PRIMARY KEY (id);


--
-- Name: recurrences recurrences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences
    ADD CONSTRAINT recurrences_pkey PRIMARY KEY (id);


--
-- Name: recurrences_repetitions recurrences_repetitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_repetitions
    ADD CONSTRAINT recurrences_repetitions_pkey PRIMARY KEY (id);


--
-- Name: recurrences_transactions recurrences_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_transactions
    ADD CONSTRAINT recurrences_transactions_pkey PRIMARY KEY (id);


--
-- Name: role_user role_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_user
    ADD CONSTRAINT role_user_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: roles roles_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_unique UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: rt_meta rt_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rt_meta
    ADD CONSTRAINT rt_meta_pkey PRIMARY KEY (id);


--
-- Name: rule_actions rule_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_actions
    ADD CONSTRAINT rule_actions_pkey PRIMARY KEY (id);


--
-- Name: rule_groups rule_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_groups
    ADD CONSTRAINT rule_groups_pkey PRIMARY KEY (id);


--
-- Name: rule_triggers rule_triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_triggers
    ADD CONSTRAINT rule_triggers_pkey PRIMARY KEY (id);


--
-- Name: rules rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_id_unique UNIQUE (id);


--
-- Name: tag_transaction_journal tag_transaction_journal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_transaction_journal
    ADD CONSTRAINT tag_transaction_journal_pkey PRIMARY KEY (id);


--
-- Name: tag_transaction_journal tag_transaction_journal_tag_id_transaction_journal_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_transaction_journal
    ADD CONSTRAINT tag_transaction_journal_tag_id_transaction_journal_id_unique UNIQUE (tag_id, transaction_journal_id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: transaction_currencies transaction_currencies_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currencies
    ADD CONSTRAINT transaction_currencies_code_unique UNIQUE (code);


--
-- Name: transaction_currencies transaction_currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currencies
    ADD CONSTRAINT transaction_currencies_pkey PRIMARY KEY (id);


--
-- Name: transaction_currency_user_group transaction_currency_user_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currency_user_group
    ADD CONSTRAINT transaction_currency_user_group_pkey PRIMARY KEY (id);


--
-- Name: transaction_currency_user transaction_currency_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currency_user
    ADD CONSTRAINT transaction_currency_user_pkey PRIMARY KEY (id);


--
-- Name: transaction_groups transaction_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_groups
    ADD CONSTRAINT transaction_groups_pkey PRIMARY KEY (id);


--
-- Name: transaction_journals transaction_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_journals
    ADD CONSTRAINT transaction_journals_pkey PRIMARY KEY (id);


--
-- Name: transaction_types transaction_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_types
    ADD CONSTRAINT transaction_types_pkey PRIMARY KEY (id);


--
-- Name: transaction_types transaction_types_type_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_types
    ADD CONSTRAINT transaction_types_type_unique UNIQUE (type);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: account_balances unique_account_currency; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_balances
    ADD CONSTRAINT unique_account_currency UNIQUE (account_id, transaction_currency_id, transaction_journal_id, date, title);


--
-- Name: transaction_currency_user unique_combo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currency_user
    ADD CONSTRAINT unique_combo UNIQUE (user_id, transaction_currency_id);


--
-- Name: transaction_currency_user_group unique_combo_ug; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currency_user_group
    ADD CONSTRAINT unique_combo_ug UNIQUE (user_group_id, transaction_currency_id);


--
-- Name: group_journals unique_in_group; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_journals
    ADD CONSTRAINT unique_in_group UNIQUE (transaction_group_id, transaction_journal_id);


--
-- Name: account_piggy_bank unique_piggy_save; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_piggy_bank
    ADD CONSTRAINT unique_piggy_save UNIQUE (account_id, piggy_bank_id);


--
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id);


--
-- Name: user_groups user_groups_title_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_title_unique UNIQUE (title);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_title_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_title_unique UNIQUE (title);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webhook_attempts webhook_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_attempts
    ADD CONSTRAINT webhook_attempts_pkey PRIMARY KEY (id);


--
-- Name: webhook_deliveries webhook_deliveries_key_title_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_key_title_unique UNIQUE (key, title);


--
-- Name: webhook_deliveries webhook_deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_pkey PRIMARY KEY (id);


--
-- Name: webhook_messages webhook_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_messages
    ADD CONSTRAINT webhook_messages_pkey PRIMARY KEY (id);


--
-- Name: webhook_responses webhook_responses_key_title_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_responses
    ADD CONSTRAINT webhook_responses_key_title_unique UNIQUE (key, title);


--
-- Name: webhook_responses webhook_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_responses
    ADD CONSTRAINT webhook_responses_pkey PRIMARY KEY (id);


--
-- Name: webhook_triggers webhook_triggers_key_title_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_triggers
    ADD CONSTRAINT webhook_triggers_key_title_unique UNIQUE (key, title);


--
-- Name: webhook_triggers webhook_triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_triggers
    ADD CONSTRAINT webhook_triggers_pkey PRIMARY KEY (id);


--
-- Name: webhook_webhook_delivery webhook_webhook_delivery_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_delivery
    ADD CONSTRAINT webhook_webhook_delivery_pkey PRIMARY KEY (id);


--
-- Name: webhook_webhook_delivery webhook_webhook_delivery_webhook_id_webhook_delivery_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_delivery
    ADD CONSTRAINT webhook_webhook_delivery_webhook_id_webhook_delivery_id_unique UNIQUE (webhook_id, webhook_delivery_id);


--
-- Name: webhook_webhook_response webhook_webhook_response_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_response
    ADD CONSTRAINT webhook_webhook_response_pkey PRIMARY KEY (id);


--
-- Name: webhook_webhook_response webhook_webhook_response_webhook_id_webhook_response_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_response
    ADD CONSTRAINT webhook_webhook_response_webhook_id_webhook_response_id_unique UNIQUE (webhook_id, webhook_response_id);


--
-- Name: webhook_webhook_trigger webhook_webhook_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_trigger
    ADD CONSTRAINT webhook_webhook_trigger_pkey PRIMARY KEY (id);


--
-- Name: webhook_webhook_trigger webhook_webhook_trigger_webhook_id_webhook_trigger_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_trigger
    ADD CONSTRAINT webhook_webhook_trigger_webhook_id_webhook_trigger_id_unique UNIQUE (webhook_id, webhook_trigger_id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: account_meta_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_meta_account_id_index ON public.account_meta USING btree (account_id);


--
-- Name: accounts_account_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_account_type_id_index ON public.accounts USING btree (account_type_id);


--
-- Name: accounts_user_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_user_group_id_index ON public.accounts USING btree (user_group_id);


--
-- Name: accounts_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_user_id_index ON public.accounts USING btree (user_id);


--
-- Name: budgets_user_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX budgets_user_group_id_index ON public.budgets USING btree (user_group_id);


--
-- Name: budgets_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX budgets_user_id_index ON public.budgets USING btree (user_id);


--
-- Name: categories_user_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX categories_user_group_id_index ON public.categories USING btree (user_group_id);


--
-- Name: categories_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX categories_user_id_index ON public.categories USING btree (user_id);


--
-- Name: category_transaction_journal_transaction_journal_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_transaction_journal_transaction_journal_id_index ON public.category_transaction_journal USING btree (transaction_journal_id);


--
-- Name: idx_tj_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tj_deleted ON public.transaction_journals USING btree (deleted_at);


--
-- Name: idx_ttj_journal_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ttj_journal_tag ON public.tag_transaction_journal USING btree (transaction_journal_id, tag_id);


--
-- Name: idx_tx_journal_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tx_journal_amount ON public.transactions USING btree (transaction_journal_id, amount);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: journal_meta_data_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX journal_meta_data_index ON public.journal_meta USING btree (data);


--
-- Name: journal_meta_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX journal_meta_name_index ON public.journal_meta USING btree (name);


--
-- Name: journal_meta_transaction_journal_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX journal_meta_transaction_journal_id_index ON public.journal_meta USING btree (transaction_journal_id);


--
-- Name: notifications_notifiable_type_notifiable_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_notifiable_type_notifiable_id_index ON public.notifications USING btree (notifiable_type, notifiable_id);


--
-- Name: oauth_access_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth_access_tokens_user_id_index ON public.oauth_access_tokens USING btree (user_id);


--
-- Name: oauth_auth_codes_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth_auth_codes_user_id_index ON public.oauth_auth_codes USING btree (user_id);


--
-- Name: oauth_clients_owner_type_owner_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth_clients_owner_type_owner_id_index ON public.oauth_clients USING btree (owner_type, owner_id);


--
-- Name: oauth_device_codes_client_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth_device_codes_client_id_index ON public.oauth_device_codes USING btree (client_id);


--
-- Name: oauth_device_codes_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth_device_codes_user_id_index ON public.oauth_device_codes USING btree (user_id);


--
-- Name: oauth_refresh_tokens_access_token_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth_refresh_tokens_access_token_id_index ON public.oauth_refresh_tokens USING btree (access_token_id);


--
-- Name: password_resets_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX password_resets_email_index ON public.password_resets USING btree (email);


--
-- Name: password_resets_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX password_resets_token_index ON public.password_resets USING btree (token);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: transaction_groups_user_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_groups_user_group_id_index ON public.transaction_groups USING btree (user_group_id);


--
-- Name: transaction_groups_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_groups_user_id_index ON public.transaction_groups USING btree (user_id);


--
-- Name: transaction_journals_bill_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_journals_bill_id_index ON public.transaction_journals USING btree (bill_id);


--
-- Name: transaction_journals_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_journals_date_index ON public.transaction_journals USING btree (date);


--
-- Name: transaction_journals_transaction_currency_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_journals_transaction_currency_id_index ON public.transaction_journals USING btree (transaction_currency_id);


--
-- Name: transaction_journals_transaction_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_journals_transaction_group_id_index ON public.transaction_journals USING btree (transaction_group_id);


--
-- Name: transaction_journals_transaction_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_journals_transaction_type_id_index ON public.transaction_journals USING btree (transaction_type_id);


--
-- Name: transaction_journals_user_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_journals_user_group_id_index ON public.transaction_journals USING btree (user_group_id);


--
-- Name: transaction_journals_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transaction_journals_user_id_index ON public.transaction_journals USING btree (user_id);


--
-- Name: transactions_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transactions_account_id_index ON public.transactions USING btree (account_id);


--
-- Name: transactions_foreign_currency_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transactions_foreign_currency_id_index ON public.transactions USING btree (foreign_currency_id);


--
-- Name: transactions_transaction_currency_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transactions_transaction_currency_id_index ON public.transactions USING btree (transaction_currency_id);


--
-- Name: transactions_transaction_journal_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transactions_transaction_journal_id_index ON public.transactions USING btree (transaction_journal_id);


--
-- Name: webhooks_secret_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX webhooks_secret_index ON public.webhooks USING btree (secret);


--
-- Name: webhooks_title_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX webhooks_title_index ON public.webhooks USING btree (title);


--
-- Name: 2fa_tokens 2fa_tokens_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2fa_tokens"
    ADD CONSTRAINT "2fa_tokens_user_id_foreign" FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: account_balances account_balances_account_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_balances
    ADD CONSTRAINT account_balances_account_id_foreign FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_balances account_balances_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_balances
    ADD CONSTRAINT account_balances_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: account_balances account_balances_transaction_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_balances
    ADD CONSTRAINT account_balances_transaction_journal_id_foreign FOREIGN KEY (transaction_journal_id) REFERENCES public.transaction_journals(id) ON DELETE CASCADE;


--
-- Name: account_meta account_meta_account_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_meta
    ADD CONSTRAINT account_meta_account_id_foreign FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_piggy_bank account_piggy_bank_account_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_piggy_bank
    ADD CONSTRAINT account_piggy_bank_account_id_foreign FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_piggy_bank account_piggy_bank_piggy_bank_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_piggy_bank
    ADD CONSTRAINT account_piggy_bank_piggy_bank_id_foreign FOREIGN KEY (piggy_bank_id) REFERENCES public.piggy_banks(id) ON DELETE CASCADE;


--
-- Name: accounts accounts_account_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_account_type_id_foreign FOREIGN KEY (account_type_id) REFERENCES public.account_types(id) ON DELETE CASCADE;


--
-- Name: accounts accounts_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: accounts accounts_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: attachments attachments_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: attachments attachments_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: auto_budgets auto_budgets_budget_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auto_budgets
    ADD CONSTRAINT auto_budgets_budget_id_foreign FOREIGN KEY (budget_id) REFERENCES public.budgets(id) ON DELETE CASCADE;


--
-- Name: auto_budgets auto_budgets_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auto_budgets
    ADD CONSTRAINT auto_budgets_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: available_budgets available_budgets_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.available_budgets
    ADD CONSTRAINT available_budgets_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: available_budgets available_budgets_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.available_budgets
    ADD CONSTRAINT available_budgets_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: available_budgets available_budgets_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.available_budgets
    ADD CONSTRAINT available_budgets_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bills bills_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: bills bills_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE SET NULL;


--
-- Name: bills bills_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: budget_transaction_journal budget_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_transaction_journal
    ADD CONSTRAINT budget_id_foreign FOREIGN KEY (budget_limit_id) REFERENCES public.budget_limits(id) ON DELETE SET NULL;


--
-- Name: budget_limits budget_limits_budget_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_limits
    ADD CONSTRAINT budget_limits_budget_id_foreign FOREIGN KEY (budget_id) REFERENCES public.budgets(id) ON DELETE CASCADE;


--
-- Name: budget_limits budget_limits_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_limits
    ADD CONSTRAINT budget_limits_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE SET NULL;


--
-- Name: budget_transaction budget_transaction_budget_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_transaction
    ADD CONSTRAINT budget_transaction_budget_id_foreign FOREIGN KEY (budget_id) REFERENCES public.budgets(id) ON DELETE CASCADE;


--
-- Name: budget_transaction_journal budget_transaction_journal_budget_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_transaction_journal
    ADD CONSTRAINT budget_transaction_journal_budget_id_foreign FOREIGN KEY (budget_id) REFERENCES public.budgets(id) ON DELETE CASCADE;


--
-- Name: budget_transaction_journal budget_transaction_journal_transaction_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_transaction_journal
    ADD CONSTRAINT budget_transaction_journal_transaction_journal_id_foreign FOREIGN KEY (transaction_journal_id) REFERENCES public.transaction_journals(id) ON DELETE CASCADE;


--
-- Name: budget_transaction budget_transaction_transaction_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_transaction
    ADD CONSTRAINT budget_transaction_transaction_id_foreign FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE CASCADE;


--
-- Name: budgets budgets_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: budgets budgets_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: categories categories_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: categories categories_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: category_transaction category_transaction_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_transaction
    ADD CONSTRAINT category_transaction_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: category_transaction_journal category_transaction_journal_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_transaction_journal
    ADD CONSTRAINT category_transaction_journal_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: category_transaction_journal category_transaction_journal_transaction_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_transaction_journal
    ADD CONSTRAINT category_transaction_journal_transaction_journal_id_foreign FOREIGN KEY (transaction_journal_id) REFERENCES public.transaction_journals(id) ON DELETE CASCADE;


--
-- Name: category_transaction category_transaction_transaction_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_transaction
    ADD CONSTRAINT category_transaction_transaction_id_foreign FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE CASCADE;


--
-- Name: currency_exchange_rates cer_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_exchange_rates
    ADD CONSTRAINT cer_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: currency_exchange_rates currency_exchange_rates_from_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_exchange_rates
    ADD CONSTRAINT currency_exchange_rates_from_currency_id_foreign FOREIGN KEY (from_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: currency_exchange_rates currency_exchange_rates_to_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_exchange_rates
    ADD CONSTRAINT currency_exchange_rates_to_currency_id_foreign FOREIGN KEY (to_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: currency_exchange_rates currency_exchange_rates_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_exchange_rates
    ADD CONSTRAINT currency_exchange_rates_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: group_journals group_journals_transaction_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_journals
    ADD CONSTRAINT group_journals_transaction_group_id_foreign FOREIGN KEY (transaction_group_id) REFERENCES public.transaction_groups(id) ON DELETE CASCADE;


--
-- Name: group_journals group_journals_transaction_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_journals
    ADD CONSTRAINT group_journals_transaction_journal_id_foreign FOREIGN KEY (transaction_journal_id) REFERENCES public.transaction_journals(id) ON DELETE CASCADE;


--
-- Name: group_memberships group_memberships_user_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_memberships
    ADD CONSTRAINT group_memberships_user_group_id_foreign FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_memberships group_memberships_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_memberships
    ADD CONSTRAINT group_memberships_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_memberships group_memberships_user_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_memberships
    ADD CONSTRAINT group_memberships_user_role_id_foreign FOREIGN KEY (user_role_id) REFERENCES public.user_roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invited_users invited_users_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invited_users
    ADD CONSTRAINT invited_users_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: journal_links journal_links_destination_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_links
    ADD CONSTRAINT journal_links_destination_id_foreign FOREIGN KEY (destination_id) REFERENCES public.transaction_journals(id) ON DELETE CASCADE;


--
-- Name: journal_links journal_links_link_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_links
    ADD CONSTRAINT journal_links_link_type_id_foreign FOREIGN KEY (link_type_id) REFERENCES public.link_types(id) ON DELETE CASCADE;


--
-- Name: journal_links journal_links_source_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_links
    ADD CONSTRAINT journal_links_source_id_foreign FOREIGN KEY (source_id) REFERENCES public.transaction_journals(id) ON DELETE CASCADE;


--
-- Name: journal_meta journal_meta_transaction_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_meta
    ADD CONSTRAINT journal_meta_transaction_journal_id_foreign FOREIGN KEY (transaction_journal_id) REFERENCES public.transaction_journals(id) ON DELETE CASCADE;


--
-- Name: webhook_webhook_delivery link_to_delivery; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_delivery
    ADD CONSTRAINT link_to_delivery FOREIGN KEY (webhook_delivery_id) REFERENCES public.webhook_deliveries(id) ON DELETE CASCADE;


--
-- Name: webhook_webhook_response link_to_response; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_response
    ADD CONSTRAINT link_to_response FOREIGN KEY (webhook_response_id) REFERENCES public.webhook_responses(id) ON DELETE CASCADE;


--
-- Name: webhook_webhook_trigger link_to_trigger; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_trigger
    ADD CONSTRAINT link_to_trigger FOREIGN KEY (webhook_trigger_id) REFERENCES public.webhook_triggers(id) ON DELETE CASCADE;


--
-- Name: object_groups object_groups_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_groups
    ADD CONSTRAINT object_groups_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: object_groups object_groups_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_groups
    ADD CONSTRAINT object_groups_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: period_statistics period_statistics_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.period_statistics
    ADD CONSTRAINT period_statistics_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: period_statistics period_statistics_user_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.period_statistics
    ADD CONSTRAINT period_statistics_user_group_id_foreign FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON DELETE CASCADE;


--
-- Name: permission_role permission_role_permission_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_role
    ADD CONSTRAINT permission_role_permission_id_foreign FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: permission_role permission_role_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_role
    ADD CONSTRAINT permission_role_role_id_foreign FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: piggy_bank_events piggy_bank_events_piggy_bank_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_bank_events
    ADD CONSTRAINT piggy_bank_events_piggy_bank_id_foreign FOREIGN KEY (piggy_bank_id) REFERENCES public.piggy_banks(id) ON DELETE CASCADE;


--
-- Name: piggy_bank_events piggy_bank_events_transaction_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_bank_events
    ADD CONSTRAINT piggy_bank_events_transaction_journal_id_foreign FOREIGN KEY (transaction_journal_id) REFERENCES public.transaction_journals(id) ON DELETE SET NULL;


--
-- Name: piggy_bank_repetitions piggy_bank_repetitions_piggy_bank_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_bank_repetitions
    ADD CONSTRAINT piggy_bank_repetitions_piggy_bank_id_foreign FOREIGN KEY (piggy_bank_id) REFERENCES public.piggy_banks(id) ON DELETE CASCADE;


--
-- Name: piggy_banks piggy_banks_account_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_banks
    ADD CONSTRAINT piggy_banks_account_id_foreign FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: preferences preferences_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: preferences preferences_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: recurrences_meta recurrences_meta_recurrence_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_meta
    ADD CONSTRAINT recurrences_meta_recurrence_id_foreign FOREIGN KEY (recurrence_id) REFERENCES public.recurrences(id) ON DELETE CASCADE;


--
-- Name: recurrences_repetitions recurrences_repetitions_recurrence_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_repetitions
    ADD CONSTRAINT recurrences_repetitions_recurrence_id_foreign FOREIGN KEY (recurrence_id) REFERENCES public.recurrences(id) ON DELETE CASCADE;


--
-- Name: recurrences recurrences_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences
    ADD CONSTRAINT recurrences_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: recurrences recurrences_transaction_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences
    ADD CONSTRAINT recurrences_transaction_type_id_foreign FOREIGN KEY (transaction_type_id) REFERENCES public.transaction_types(id) ON DELETE CASCADE;


--
-- Name: recurrences_transactions recurrences_transactions_destination_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_transactions
    ADD CONSTRAINT recurrences_transactions_destination_id_foreign FOREIGN KEY (destination_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: recurrences_transactions recurrences_transactions_foreign_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_transactions
    ADD CONSTRAINT recurrences_transactions_foreign_currency_id_foreign FOREIGN KEY (foreign_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE SET NULL;


--
-- Name: recurrences_transactions recurrences_transactions_recurrence_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_transactions
    ADD CONSTRAINT recurrences_transactions_recurrence_id_foreign FOREIGN KEY (recurrence_id) REFERENCES public.recurrences(id) ON DELETE CASCADE;


--
-- Name: recurrences_transactions recurrences_transactions_source_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_transactions
    ADD CONSTRAINT recurrences_transactions_source_id_foreign FOREIGN KEY (source_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: recurrences_transactions recurrences_transactions_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_transactions
    ADD CONSTRAINT recurrences_transactions_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: recurrences recurrences_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences
    ADD CONSTRAINT recurrences_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: role_user role_user_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_user
    ADD CONSTRAINT role_user_role_id_foreign FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: role_user role_user_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_user
    ADD CONSTRAINT role_user_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rt_meta rt_meta_rt_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rt_meta
    ADD CONSTRAINT rt_meta_rt_id_foreign FOREIGN KEY (rt_id) REFERENCES public.recurrences_transactions(id) ON DELETE CASCADE;


--
-- Name: rule_actions rule_actions_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_actions
    ADD CONSTRAINT rule_actions_rule_id_foreign FOREIGN KEY (rule_id) REFERENCES public.rules(id) ON DELETE CASCADE;


--
-- Name: rule_groups rule_groups_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_groups
    ADD CONSTRAINT rule_groups_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: rule_groups rule_groups_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_groups
    ADD CONSTRAINT rule_groups_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rule_triggers rule_triggers_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_triggers
    ADD CONSTRAINT rule_triggers_rule_id_foreign FOREIGN KEY (rule_id) REFERENCES public.rules(id) ON DELETE CASCADE;


--
-- Name: rules rules_rule_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_rule_group_id_foreign FOREIGN KEY (rule_group_id) REFERENCES public.rule_groups(id) ON DELETE CASCADE;


--
-- Name: rules rules_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: rules rules_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tag_transaction_journal tag_transaction_journal_tag_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_transaction_journal
    ADD CONSTRAINT tag_transaction_journal_tag_id_foreign FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: tag_transaction_journal tag_transaction_journal_transaction_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_transaction_journal
    ADD CONSTRAINT tag_transaction_journal_transaction_journal_id_foreign FOREIGN KEY (transaction_journal_id) REFERENCES public.transaction_journals(id) ON DELETE CASCADE;


--
-- Name: tags tags_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tags tags_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: transaction_currency_user_group transaction_currency_user_group_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currency_user_group
    ADD CONSTRAINT transaction_currency_user_group_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: transaction_currency_user_group transaction_currency_user_group_user_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currency_user_group
    ADD CONSTRAINT transaction_currency_user_group_user_group_id_foreign FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON DELETE CASCADE;


--
-- Name: transaction_currency_user transaction_currency_user_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currency_user
    ADD CONSTRAINT transaction_currency_user_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: transaction_currency_user transaction_currency_user_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_currency_user
    ADD CONSTRAINT transaction_currency_user_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: transaction_groups transaction_groups_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_groups
    ADD CONSTRAINT transaction_groups_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: transaction_groups transaction_groups_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_groups
    ADD CONSTRAINT transaction_groups_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: transaction_journals transaction_journals_bill_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_journals
    ADD CONSTRAINT transaction_journals_bill_id_foreign FOREIGN KEY (bill_id) REFERENCES public.bills(id) ON DELETE SET NULL;


--
-- Name: transaction_journals transaction_journals_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_journals
    ADD CONSTRAINT transaction_journals_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: transaction_journals transaction_journals_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_journals
    ADD CONSTRAINT transaction_journals_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: transaction_journals transaction_journals_transaction_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_journals
    ADD CONSTRAINT transaction_journals_transaction_group_id_foreign FOREIGN KEY (transaction_group_id) REFERENCES public.transaction_groups(id) ON DELETE CASCADE;


--
-- Name: transaction_journals transaction_journals_transaction_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_journals
    ADD CONSTRAINT transaction_journals_transaction_type_id_foreign FOREIGN KEY (transaction_type_id) REFERENCES public.transaction_types(id) ON DELETE CASCADE;


--
-- Name: transaction_journals transaction_journals_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_journals
    ADD CONSTRAINT transaction_journals_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_account_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_account_id_foreign FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_foreign_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_foreign_currency_id_foreign FOREIGN KEY (foreign_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_transaction_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_transaction_currency_id_foreign FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_transaction_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_transaction_journal_id_foreign FOREIGN KEY (transaction_journal_id) REFERENCES public.transaction_journals(id) ON DELETE CASCADE;


--
-- Name: recurrences_transactions type_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurrences_transactions
    ADD CONSTRAINT type_foreign FOREIGN KEY (transaction_type_id) REFERENCES public.transaction_types(id) ON DELETE SET NULL;


--
-- Name: users type_user_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT type_user_group_id FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: piggy_banks unique_currency; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piggy_banks
    ADD CONSTRAINT unique_currency FOREIGN KEY (transaction_currency_id) REFERENCES public.transaction_currencies(id) ON DELETE CASCADE;


--
-- Name: webhook_attempts webhook_attempts_webhook_message_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_attempts
    ADD CONSTRAINT webhook_attempts_webhook_message_id_foreign FOREIGN KEY (webhook_message_id) REFERENCES public.webhook_messages(id) ON DELETE CASCADE;


--
-- Name: webhook_messages webhook_messages_webhook_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_messages
    ADD CONSTRAINT webhook_messages_webhook_id_foreign FOREIGN KEY (webhook_id) REFERENCES public.webhooks(id) ON DELETE CASCADE;


--
-- Name: webhook_webhook_delivery webhook_webhook_delivery_webhook_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_delivery
    ADD CONSTRAINT webhook_webhook_delivery_webhook_id_foreign FOREIGN KEY (webhook_id) REFERENCES public.webhooks(id) ON DELETE CASCADE;


--
-- Name: webhook_webhook_response webhook_webhook_response_webhook_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_response
    ADD CONSTRAINT webhook_webhook_response_webhook_id_foreign FOREIGN KEY (webhook_id) REFERENCES public.webhooks(id) ON DELETE CASCADE;


--
-- Name: webhook_webhook_trigger webhook_webhook_trigger_webhook_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_webhook_trigger
    ADD CONSTRAINT webhook_webhook_trigger_webhook_id_foreign FOREIGN KEY (webhook_id) REFERENCES public.webhooks(id) ON DELETE CASCADE;


--
-- Name: webhooks webhooks_to_ugi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_to_ugi FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: webhooks webhooks_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


