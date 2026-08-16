--
-- PostgreSQL database dump
--


-- Dumped from database version 17.11 (Debian 17.11-1.pgdg13+2)
-- Dumped by pg_dump version 17.11 (Debian 17.11-1.pgdg13+2)

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

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: author_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.author_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                begin
                    WITH book AS (
                        SELECT bookwyrm_book.id as row_id
                        FROM bookwyrm_author
                        LEFT OUTER JOIN bookwyrm_book_authors
                        ON bookwyrm_book_authors.id = new.id
                        LEFT OUTER JOIN bookwyrm_book
                        ON bookwyrm_book.id = bookwyrm_book_authors.book_id
                    )
                    UPDATE bookwyrm_book SET search_vector = ''
                    FROM book
                    WHERE id = book.row_id;
                    return new;
                end
                $$;


--
-- Name: book_authors_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.book_authors_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                begin
                    UPDATE bookwyrm_book SET search_vector = ''
                    WHERE id = coalesce(new.book_id, old.book_id);
                    return new;
                end
                $$;


--
-- Name: book_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.book_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                begin
                    new.search_vector :=
                        coalesce(
                            NULLIF(setweight(to_tsvector('english', coalesce(new.title, '')), 'A'), ''),
                            setweight(to_tsvector('simple', coalesce(new.title, '')), 'A')
                        ) ||
                        setweight(to_tsvector('english', coalesce(new.subtitle, '')), 'B') ||
                        (SELECT setweight(to_tsvector('simple', coalesce(array_to_string(array_agg(bookwyrm_author.name), ' '), '')), 'C')
                            FROM bookwyrm_book
                            LEFT OUTER JOIN bookwyrm_book_authors
                            ON bookwyrm_book.id = bookwyrm_book_authors.book_id
                            LEFT OUTER JOIN bookwyrm_author
                            ON bookwyrm_book_authors.author_id = bookwyrm_author.id
                            WHERE bookwyrm_book.id = new.id
                        ) ||
                        setweight(to_tsvector('english', coalesce(new.series, '')), 'D');
                    return new;
                end
                $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- Name: bookwyrm_announcement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_announcement (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    preview character varying(255) NOT NULL,
    content text,
    event_date timestamp with time zone,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    active boolean NOT NULL,
    user_id integer NOT NULL,
    display_type character varying(20)
);


--
-- Name: bookwyrm_announcement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_announcement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_announcement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_announcement_id_seq OWNED BY public.bookwyrm_announcement.id;


--
-- Name: bookwyrm_annualgoal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_annualgoal (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    goal integer NOT NULL,
    year integer NOT NULL,
    privacy character varying(255) NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_annualgoal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_annualgoal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_annualgoal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_annualgoal_id_seq OWNED BY public.bookwyrm_annualgoal.id;


--
-- Name: bookwyrm_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_image (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    image character varying(100),
    caption text,
    status_id integer
);


--
-- Name: bookwyrm_attachment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_attachment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_attachment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_attachment_id_seq OWNED BY public.bookwyrm_image.id;


--
-- Name: bookwyrm_author; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_author (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    openlibrary_key character varying(255),
    updated_date timestamp with time zone NOT NULL,
    bio text,
    born timestamp with time zone,
    died timestamp with time zone,
    name character varying(255) NOT NULL,
    wikipedia_link character varying(255),
    aliases character varying(255)[] NOT NULL,
    remote_id character varying(255),
    origin_id character varying(255),
    goodreads_key character varying(255),
    last_edited_by_id integer,
    librarything_key character varying(255),
    bnf_id character varying(255),
    gutenberg_id character varying(255),
    inventaire_id character varying(255),
    isni character varying(255),
    viaf character varying(255),
    search_vector tsvector,
    asin character varying(255),
    wikidata character varying(255),
    aasin character varying(255),
    isfdb character varying(255),
    website character varying(255)
);


--
-- Name: bookwyrm_author_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_author_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_author_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_author_id_seq OWNED BY public.bookwyrm_author.id;


--
-- Name: bookwyrm_automod; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_automod (
    id integer NOT NULL,
    string_match character varying(200) NOT NULL,
    flag_users boolean NOT NULL,
    flag_statuses boolean NOT NULL,
    created_by_id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    updated_date timestamp with time zone NOT NULL
);


--
-- Name: bookwyrm_automod_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_automod_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_automod_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_automod_id_seq OWNED BY public.bookwyrm_automod.id;


--
-- Name: bookwyrm_book; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_book (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    openlibrary_key character varying(255),
    cover character varying(100),
    updated_date timestamp with time zone NOT NULL,
    description text,
    first_published_date timestamp with time zone,
    librarything_key character varying(255),
    published_date timestamp with time zone,
    series text,
    series_number character varying(255),
    sort_title character varying(255),
    subtitle text,
    title text NOT NULL,
    connector_id integer,
    subject_places character varying(255)[],
    subjects character varying(255)[],
    goodreads_key character varying(255),
    languages character varying(255)[] NOT NULL,
    remote_id character varying(255),
    origin_id character varying(255),
    last_edited_by_id integer,
    bnf_id character varying(255),
    inventaire_id character varying(255),
    preview_image character varying(100),
    search_vector tsvector,
    asin character varying(255),
    viaf character varying(255),
    wikidata character varying(255),
    aasin character varying(255),
    isfdb character varying(255)
);


--
-- Name: bookwyrm_book_authors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_book_authors (
    id integer NOT NULL,
    book_id integer NOT NULL,
    author_id integer NOT NULL
);


--
-- Name: bookwyrm_book_authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_book_authors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_book_authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_book_authors_id_seq OWNED BY public.bookwyrm_book_authors.id;


--
-- Name: bookwyrm_book_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_book_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_book_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_book_id_seq OWNED BY public.bookwyrm_book.id;


--
-- Name: bookwyrm_boost; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_boost (
    status_ptr_id integer NOT NULL,
    boosted_status_id integer NOT NULL
);


--
-- Name: bookwyrm_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_comment (
    status_ptr_id integer NOT NULL,
    book_id integer NOT NULL,
    progress integer,
    progress_mode character varying(3),
    reading_status character varying(255)
);


--
-- Name: bookwyrm_connector; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_connector (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    identifier character varying(255) NOT NULL,
    connector_file character varying(255) NOT NULL,
    api_key character varying(255),
    base_url character varying(255) NOT NULL,
    covers_url character varying(255) NOT NULL,
    search_url character varying(255),
    books_url character varying(255) NOT NULL,
    name character varying(255),
    priority integer NOT NULL,
    remote_id character varying(255),
    isbn_search_url character varying(255),
    active boolean NOT NULL,
    deactivation_reason character varying(255)
);


--
-- Name: bookwyrm_connector_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_connector_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_connector_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_connector_id_seq OWNED BY public.bookwyrm_connector.id;


--
-- Name: bookwyrm_edition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_edition (
    book_ptr_id integer NOT NULL,
    isbn_13 character varying(255),
    oclc_number character varying(255),
    pages integer,
    publishers character varying(255)[] NOT NULL,
    physical_format_detail character varying(255),
    parent_work_id integer,
    isbn_10 character varying(255),
    edition_rank integer NOT NULL,
    physical_format character varying(255)
);


--
-- Name: bookwyrm_emailblocklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_emailblocklist (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    domain character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    remote_id character varying(255),
    updated_date timestamp with time zone NOT NULL
);


--
-- Name: bookwyrm_emailblocklist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_emailblocklist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_emailblocklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_emailblocklist_id_seq OWNED BY public.bookwyrm_emailblocklist.id;


--
-- Name: bookwyrm_favorite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_favorite (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    status_id integer NOT NULL,
    user_id integer NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255)
);


--
-- Name: bookwyrm_favorite_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_favorite_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_favorite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_favorite_id_seq OWNED BY public.bookwyrm_favorite.id;


--
-- Name: bookwyrm_federatedserver; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_federatedserver (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    server_name character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    application_type character varying(255),
    updated_date timestamp with time zone NOT NULL,
    application_version character varying(255),
    remote_id character varying(255),
    notes text
);


--
-- Name: bookwyrm_federatedserver_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_federatedserver_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_federatedserver_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_federatedserver_id_seq OWNED BY public.bookwyrm_federatedserver.id;


--
-- Name: bookwyrm_filelink; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_filelink (
    link_ptr_id integer NOT NULL,
    filetype character varying(50) NOT NULL,
    book_id integer,
    availability character varying(100) NOT NULL
);


--
-- Name: bookwyrm_generatednote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_generatednote (
    status_ptr_id integer NOT NULL
);


--
-- Name: bookwyrm_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_group (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    name character varying(100) NOT NULL,
    description text,
    privacy character varying(255) NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_group_id_seq OWNED BY public.bookwyrm_group.id;


--
-- Name: bookwyrm_groupmember; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_groupmember (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    group_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_groupmember_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_groupmember_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_groupmember_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_groupmember_id_seq OWNED BY public.bookwyrm_groupmember.id;


--
-- Name: bookwyrm_groupmemberinvitation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_groupmemberinvitation (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    group_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_groupmemberinvitation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_groupmemberinvitation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_groupmemberinvitation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_groupmemberinvitation_id_seq OWNED BY public.bookwyrm_groupmemberinvitation.id;


--
-- Name: bookwyrm_hashtag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_hashtag (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    name public.citext NOT NULL
);


--
-- Name: bookwyrm_hashtag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_hashtag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_hashtag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_hashtag_id_seq OWNED BY public.bookwyrm_hashtag.id;


--
-- Name: bookwyrm_importitem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_importitem (
    id integer NOT NULL,
    data jsonb NOT NULL,
    book_id integer,
    job_id integer NOT NULL,
    fail_reason text,
    index integer NOT NULL,
    book_guess_id integer,
    normalized_data jsonb NOT NULL,
    linked_review_id integer,
    task_id character varying(200)
);


--
-- Name: bookwyrm_importitem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_importitem_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_importitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_importitem_id_seq OWNED BY public.bookwyrm_importitem.id;


--
-- Name: bookwyrm_importjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_importjob (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    user_id integer NOT NULL,
    include_reviews boolean NOT NULL,
    privacy character varying(255) NOT NULL,
    retry boolean NOT NULL,
    complete boolean NOT NULL,
    mappings jsonb NOT NULL,
    source character varying(100) NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    status character varying(50),
    task_id character varying(200)
);


--
-- Name: bookwyrm_importjob_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_importjob_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_importjob_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_importjob_id_seq OWNED BY public.bookwyrm_importjob.id;


--
-- Name: bookwyrm_inviterequest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_inviterequest (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    email character varying(255) NOT NULL,
    invite_sent boolean NOT NULL,
    ignored boolean NOT NULL,
    invite_id integer,
    answer text
);


--
-- Name: bookwyrm_inviterequest_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_inviterequest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_inviterequest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_inviterequest_id_seq OWNED BY public.bookwyrm_inviterequest.id;


--
-- Name: bookwyrm_ipblocklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_ipblocklist (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    address character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    remote_id character varying(255),
    updated_date timestamp with time zone NOT NULL
);


--
-- Name: bookwyrm_ipblocklist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_ipblocklist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_ipblocklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_ipblocklist_id_seq OWNED BY public.bookwyrm_ipblocklist.id;


--
-- Name: bookwyrm_keypair; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_keypair (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    private_key text,
    public_key text
);


--
-- Name: bookwyrm_keypair_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_keypair_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_keypair_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_keypair_id_seq OWNED BY public.bookwyrm_keypair.id;


--
-- Name: bookwyrm_link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_link (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    url character varying(255) NOT NULL,
    added_by_id integer,
    domain_id integer
);


--
-- Name: bookwyrm_link_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_link_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_link_id_seq OWNED BY public.bookwyrm_link.id;


--
-- Name: bookwyrm_linkdomain; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_linkdomain (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    domain character varying(255) NOT NULL,
    status character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    reported_by_id integer
);


--
-- Name: bookwyrm_linkdomain_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_linkdomain_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_linkdomain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_linkdomain_id_seq OWNED BY public.bookwyrm_linkdomain.id;


--
-- Name: bookwyrm_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_list (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    name character varying(100) NOT NULL,
    description text,
    privacy character varying(255) NOT NULL,
    curation character varying(255) NOT NULL,
    user_id integer NOT NULL,
    group_id integer,
    embed_key uuid
);


--
-- Name: bookwyrm_list_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_list_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_list_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_list_id_seq OWNED BY public.bookwyrm_list.id;


--
-- Name: bookwyrm_listitem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_listitem (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    notes text,
    approved boolean NOT NULL,
    "order" integer NOT NULL,
    user_id integer NOT NULL,
    book_id integer NOT NULL,
    book_list_id integer NOT NULL
);


--
-- Name: bookwyrm_listitem_endorsement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_listitem_endorsement (
    id integer NOT NULL,
    listitem_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_listitem_endorsement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_listitem_endorsement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_listitem_endorsement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_listitem_endorsement_id_seq OWNED BY public.bookwyrm_listitem_endorsement.id;


--
-- Name: bookwyrm_listitem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_listitem_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_listitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_listitem_id_seq OWNED BY public.bookwyrm_listitem.id;


--
-- Name: bookwyrm_notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_notification (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    read boolean NOT NULL,
    notification_type character varying(255) NOT NULL,
    related_status_id integer,
    user_id integer NOT NULL,
    related_import_id integer,
    remote_id character varying(255),
    related_group_id integer
);


--
-- Name: bookwyrm_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_notification_id_seq OWNED BY public.bookwyrm_notification.id;


--
-- Name: bookwyrm_notification_related_link_domains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_notification_related_link_domains (
    id integer NOT NULL,
    notification_id integer NOT NULL,
    linkdomain_id integer NOT NULL
);


--
-- Name: bookwyrm_notification_related_link_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_notification_related_link_domains_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_notification_related_link_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_notification_related_link_domains_id_seq OWNED BY public.bookwyrm_notification_related_link_domains.id;


--
-- Name: bookwyrm_notification_related_list_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_notification_related_list_items (
    id integer NOT NULL,
    notification_id integer NOT NULL,
    listitem_id integer NOT NULL
);


--
-- Name: bookwyrm_notification_related_list_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_notification_related_list_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_notification_related_list_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_notification_related_list_items_id_seq OWNED BY public.bookwyrm_notification_related_list_items.id;


--
-- Name: bookwyrm_notification_related_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_notification_related_reports (
    id integer NOT NULL,
    notification_id integer NOT NULL,
    report_id integer NOT NULL
);


--
-- Name: bookwyrm_notification_related_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_notification_related_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_notification_related_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_notification_related_reports_id_seq OWNED BY public.bookwyrm_notification_related_reports.id;


--
-- Name: bookwyrm_notification_related_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_notification_related_users (
    id integer NOT NULL,
    notification_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_notification_related_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_notification_related_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_notification_related_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_notification_related_users_id_seq OWNED BY public.bookwyrm_notification_related_users.id;


--
-- Name: bookwyrm_passwordreset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_passwordreset (
    id integer NOT NULL,
    code character varying(32) NOT NULL,
    expiry timestamp with time zone NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_passwordreset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_passwordreset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_passwordreset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_passwordreset_id_seq OWNED BY public.bookwyrm_passwordreset.id;


--
-- Name: bookwyrm_progressupdate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_progressupdate (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    progress integer NOT NULL,
    mode character varying(3) NOT NULL,
    readthrough_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_progressupdate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_progressupdate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_progressupdate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_progressupdate_id_seq OWNED BY public.bookwyrm_progressupdate.id;


--
-- Name: bookwyrm_quotation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_quotation (
    status_ptr_id integer NOT NULL,
    quote text NOT NULL,
    book_id integer NOT NULL,
    reading_status character varying(255),
    "position" integer,
    position_mode character varying(3),
    raw_quote text,
    endposition integer
);


--
-- Name: bookwyrm_readthrough; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_readthrough (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    progress integer,
    start_date timestamp with time zone,
    finish_date timestamp with time zone,
    book_id integer NOT NULL,
    user_id integer NOT NULL,
    remote_id character varying(255),
    progress_mode character varying(3) NOT NULL,
    is_active boolean NOT NULL,
    stopped_date timestamp with time zone,
    CONSTRAINT chronology CHECK ((finish_date >= start_date))
);


--
-- Name: bookwyrm_readthrough_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_readthrough_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_readthrough_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_readthrough_id_seq OWNED BY public.bookwyrm_readthrough.id;


--
-- Name: bookwyrm_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_report (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    note text,
    resolved boolean NOT NULL,
    reporter_id integer NOT NULL,
    user_id integer,
    status_id integer
);


--
-- Name: bookwyrm_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_report_id_seq OWNED BY public.bookwyrm_report.id;


--
-- Name: bookwyrm_report_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_report_links (
    id integer NOT NULL,
    report_id integer NOT NULL,
    link_id integer NOT NULL
);


--
-- Name: bookwyrm_report_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_report_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_report_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_report_links_id_seq OWNED BY public.bookwyrm_report_links.id;


--
-- Name: bookwyrm_reportcomment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_reportcomment (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    note text NOT NULL,
    report_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_reportcomment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_reportcomment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_reportcomment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_reportcomment_id_seq OWNED BY public.bookwyrm_reportcomment.id;


--
-- Name: bookwyrm_review; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_review (
    status_ptr_id integer NOT NULL,
    name character varying(255),
    rating numeric(3,2),
    book_id integer NOT NULL,
    reading_status character varying(255)
);


--
-- Name: bookwyrm_reviewrating; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_reviewrating (
    review_ptr_id integer NOT NULL
);


--
-- Name: bookwyrm_shelf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_shelf (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    identifier character varying(100) NOT NULL,
    editable boolean NOT NULL,
    user_id integer NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    privacy character varying(255) NOT NULL,
    description text
);


--
-- Name: bookwyrm_shelf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_shelf_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_shelf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_shelf_id_seq OWNED BY public.bookwyrm_shelf.id;


--
-- Name: bookwyrm_shelfbook; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_shelfbook (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    user_id integer NOT NULL,
    book_id integer NOT NULL,
    shelf_id integer NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    shelved_date timestamp with time zone NOT NULL
);


--
-- Name: bookwyrm_shelfbook_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_shelfbook_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_shelfbook_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_shelfbook_id_seq OWNED BY public.bookwyrm_shelfbook.id;


--
-- Name: bookwyrm_siteinvite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_siteinvite (
    id integer NOT NULL,
    code character varying(32) NOT NULL,
    expiry timestamp with time zone,
    use_limit integer,
    times_used integer NOT NULL,
    user_id integer NOT NULL,
    created_date timestamp with time zone NOT NULL
);


--
-- Name: bookwyrm_siteinvite_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_siteinvite_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_siteinvite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_siteinvite_id_seq OWNED BY public.bookwyrm_siteinvite.id;


--
-- Name: bookwyrm_siteinvite_invitees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_siteinvite_invitees (
    id integer NOT NULL,
    siteinvite_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_siteinvite_invitees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_siteinvite_invitees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_siteinvite_invitees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_siteinvite_invitees_id_seq OWNED BY public.bookwyrm_siteinvite_invitees.id;


--
-- Name: bookwyrm_sitesettings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_sitesettings (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    instance_description text NOT NULL,
    code_of_conduct text NOT NULL,
    allow_registration boolean NOT NULL,
    admin_email character varying(255),
    support_link character varying(255),
    support_title character varying(100),
    favicon character varying(100),
    logo character varying(100),
    logo_small character varying(100),
    instance_tagline character varying(150) NOT NULL,
    registration_closed_text text NOT NULL,
    privacy_policy text NOT NULL,
    allow_invite_requests boolean NOT NULL,
    footer_item text,
    preview_image character varying(100),
    require_confirm_email boolean NOT NULL,
    instance_short_description character varying(255),
    invite_request_text text NOT NULL,
    admin_code character varying(50) NOT NULL,
    install_mode boolean NOT NULL,
    default_theme_id integer,
    version character varying(10),
    invite_question_text character varying(255) NOT NULL,
    invite_request_question boolean NOT NULL,
    imports_enabled boolean NOT NULL,
    impressum text NOT NULL,
    show_impressum boolean NOT NULL,
    import_size_limit integer NOT NULL,
    import_limit_reset integer NOT NULL,
    default_user_auth_group_id integer
);


--
-- Name: bookwyrm_sitesettings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_sitesettings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_sitesettings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_sitesettings_id_seq OWNED BY public.bookwyrm_sitesettings.id;


--
-- Name: bookwyrm_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_status (
    id integer NOT NULL,
    content text,
    created_date timestamp with time zone NOT NULL,
    local boolean NOT NULL,
    privacy character varying(255) NOT NULL,
    sensitive boolean NOT NULL,
    reply_parent_id integer,
    user_id integer NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    published_date timestamp with time zone NOT NULL,
    remote_id character varying(255),
    deleted boolean NOT NULL,
    deleted_date timestamp with time zone,
    content_warning character varying(500),
    thread_id integer,
    edited_date timestamp with time zone,
    raw_content text,
    ready boolean NOT NULL
);


--
-- Name: bookwyrm_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_status_id_seq OWNED BY public.bookwyrm_status.id;


--
-- Name: bookwyrm_status_mention_books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_status_mention_books (
    id integer NOT NULL,
    status_id integer NOT NULL,
    edition_id integer NOT NULL
);


--
-- Name: bookwyrm_status_mention_books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_status_mention_books_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_status_mention_books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_status_mention_books_id_seq OWNED BY public.bookwyrm_status_mention_books.id;


--
-- Name: bookwyrm_status_mention_hashtags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_status_mention_hashtags (
    id integer NOT NULL,
    status_id integer NOT NULL,
    hashtag_id integer NOT NULL
);


--
-- Name: bookwyrm_status_mention_hashtags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_status_mention_hashtags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_status_mention_hashtags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_status_mention_hashtags_id_seq OWNED BY public.bookwyrm_status_mention_hashtags.id;


--
-- Name: bookwyrm_status_mention_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_status_mention_users (
    id integer NOT NULL,
    status_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: bookwyrm_status_mention_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_status_mention_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_status_mention_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_status_mention_users_id_seq OWNED BY public.bookwyrm_status_mention_users.id;


--
-- Name: bookwyrm_theme; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_theme (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    name character varying(50) NOT NULL,
    path character varying(50) NOT NULL
);


--
-- Name: bookwyrm_theme_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_theme_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_theme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_theme_id_seq OWNED BY public.bookwyrm_theme.id;


--
-- Name: bookwyrm_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254),
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    inbox character varying(255) NOT NULL,
    shared_inbox character varying(255),
    outbox character varying(255),
    summary text,
    local boolean NOT NULL,
    bookwyrm_user boolean NOT NULL,
    localname public.citext,
    name character varying(100),
    avatar character varying(100),
    federated_server_id integer,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    manually_approves_followers boolean NOT NULL,
    remote_id character varying(255),
    last_active_date timestamp with time zone NOT NULL,
    key_pair_id integer,
    show_goal boolean NOT NULL,
    discoverable boolean NOT NULL,
    preferred_timezone character varying(255) NOT NULL,
    deactivation_reason character varying(255),
    preview_image character varying(100),
    default_post_privacy character varying(255) NOT NULL,
    confirmation_code character varying(32) NOT NULL,
    followers_url character varying(255) NOT NULL,
    show_suggested_users boolean NOT NULL,
    deactivation_date timestamp with time zone,
    preferred_language character varying(255),
    feed_status_types character varying(10)[] NOT NULL,
    summary_keys jsonb,
    hide_follows boolean NOT NULL,
    theme_id integer,
    show_guided_tour boolean NOT NULL,
    hotp_count integer,
    hotp_secret character varying(32),
    otp_secret character varying(32),
    two_factor_auth boolean,
    allow_reactivation boolean NOT NULL
);


--
-- Name: bookwyrm_user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: bookwyrm_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_user_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_user_groups_id_seq OWNED BY public.bookwyrm_user_groups.id;


--
-- Name: bookwyrm_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_user_id_seq OWNED BY public.bookwyrm_user.id;


--
-- Name: bookwyrm_user_saved_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_user_saved_lists (
    id integer NOT NULL,
    user_id integer NOT NULL,
    list_id integer NOT NULL
);


--
-- Name: bookwyrm_user_saved_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_user_saved_lists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_user_saved_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_user_saved_lists_id_seq OWNED BY public.bookwyrm_user_saved_lists.id;


--
-- Name: bookwyrm_user_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: bookwyrm_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_user_user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_user_user_permissions_id_seq OWNED BY public.bookwyrm_user_user_permissions.id;


--
-- Name: bookwyrm_userblocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_userblocks (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    user_object_id integer NOT NULL,
    user_subject_id integer NOT NULL,
    remote_id character varying(255),
    CONSTRAINT userblocks_no_self CHECK ((NOT (user_subject_id = user_object_id)))
);


--
-- Name: bookwyrm_userblocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_userblocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_userblocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_userblocks_id_seq OWNED BY public.bookwyrm_userblocks.id;


--
-- Name: bookwyrm_userfollowrequest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_userfollowrequest (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    user_object_id integer NOT NULL,
    user_subject_id integer NOT NULL,
    remote_id character varying(255),
    CONSTRAINT userfollowrequest_no_self CHECK ((NOT (user_subject_id = user_object_id)))
);


--
-- Name: bookwyrm_userfollowrequest_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_userfollowrequest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_userfollowrequest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_userfollowrequest_id_seq OWNED BY public.bookwyrm_userfollowrequest.id;


--
-- Name: bookwyrm_userfollows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_userfollows (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL,
    user_object_id integer NOT NULL,
    user_subject_id integer NOT NULL,
    remote_id character varying(255),
    CONSTRAINT userfollows_no_self CHECK ((NOT (user_subject_id = user_object_id)))
);


--
-- Name: bookwyrm_userfollows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookwyrm_userfollows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookwyrm_userfollows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookwyrm_userfollows_id_seq OWNED BY public.bookwyrm_userfollows.id;


--
-- Name: bookwyrm_work; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookwyrm_work (
    book_ptr_id integer NOT NULL,
    lccn character varying(255)
);


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- Name: django_celery_beat_clockedschedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_celery_beat_clockedschedule (
    id integer NOT NULL,
    clocked_time timestamp with time zone NOT NULL
);


--
-- Name: django_celery_beat_clockedschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.django_celery_beat_clockedschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: django_celery_beat_clockedschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.django_celery_beat_clockedschedule_id_seq OWNED BY public.django_celery_beat_clockedschedule.id;


--
-- Name: django_celery_beat_crontabschedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_celery_beat_crontabschedule (
    id integer NOT NULL,
    minute character varying(240) NOT NULL,
    hour character varying(96) NOT NULL,
    day_of_week character varying(64) NOT NULL,
    day_of_month character varying(124) NOT NULL,
    month_of_year character varying(64) NOT NULL,
    timezone character varying(63) NOT NULL
);


--
-- Name: django_celery_beat_crontabschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.django_celery_beat_crontabschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: django_celery_beat_crontabschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.django_celery_beat_crontabschedule_id_seq OWNED BY public.django_celery_beat_crontabschedule.id;


--
-- Name: django_celery_beat_intervalschedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_celery_beat_intervalschedule (
    id integer NOT NULL,
    every integer NOT NULL,
    period character varying(24) NOT NULL
);


--
-- Name: django_celery_beat_intervalschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.django_celery_beat_intervalschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: django_celery_beat_intervalschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.django_celery_beat_intervalschedule_id_seq OWNED BY public.django_celery_beat_intervalschedule.id;


--
-- Name: django_celery_beat_periodictask; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_celery_beat_periodictask (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    task character varying(200) NOT NULL,
    args text NOT NULL,
    kwargs text NOT NULL,
    queue character varying(200),
    exchange character varying(200),
    routing_key character varying(200),
    expires timestamp with time zone,
    enabled boolean NOT NULL,
    last_run_at timestamp with time zone,
    total_run_count integer NOT NULL,
    date_changed timestamp with time zone NOT NULL,
    description text NOT NULL,
    crontab_id integer,
    interval_id integer,
    solar_id integer,
    one_off boolean NOT NULL,
    start_time timestamp with time zone,
    priority integer,
    headers text NOT NULL,
    clocked_id integer,
    expire_seconds integer,
    CONSTRAINT django_celery_beat_periodictask_expire_seconds_check CHECK ((expire_seconds >= 0)),
    CONSTRAINT django_celery_beat_periodictask_priority_check CHECK ((priority >= 0)),
    CONSTRAINT django_celery_beat_periodictask_total_run_count_check CHECK ((total_run_count >= 0))
);


--
-- Name: django_celery_beat_periodictask_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.django_celery_beat_periodictask_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: django_celery_beat_periodictask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.django_celery_beat_periodictask_id_seq OWNED BY public.django_celery_beat_periodictask.id;


--
-- Name: django_celery_beat_periodictasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_celery_beat_periodictasks (
    ident smallint NOT NULL,
    last_update timestamp with time zone NOT NULL
);


--
-- Name: django_celery_beat_solarschedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_celery_beat_solarschedule (
    id integer NOT NULL,
    event character varying(24) NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL
);


--
-- Name: django_celery_beat_solarschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.django_celery_beat_solarschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: django_celery_beat_solarschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.django_celery_beat_solarschedule_id_seq OWNED BY public.django_celery_beat_solarschedule.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.django_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


--
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- Name: bookwyrm_announcement id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_announcement ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_announcement_id_seq'::regclass);


--
-- Name: bookwyrm_annualgoal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_annualgoal ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_annualgoal_id_seq'::regclass);


--
-- Name: bookwyrm_author id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_author ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_author_id_seq'::regclass);


--
-- Name: bookwyrm_automod id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_automod ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_automod_id_seq'::regclass);


--
-- Name: bookwyrm_book id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_book ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_book_id_seq'::regclass);


--
-- Name: bookwyrm_book_authors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_book_authors ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_book_authors_id_seq'::regclass);


--
-- Name: bookwyrm_connector id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_connector ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_connector_id_seq'::regclass);


--
-- Name: bookwyrm_emailblocklist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_emailblocklist ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_emailblocklist_id_seq'::regclass);


--
-- Name: bookwyrm_favorite id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_favorite ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_favorite_id_seq'::regclass);


--
-- Name: bookwyrm_federatedserver id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_federatedserver ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_federatedserver_id_seq'::regclass);


--
-- Name: bookwyrm_group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_group ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_group_id_seq'::regclass);


--
-- Name: bookwyrm_groupmember id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_groupmember ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_groupmember_id_seq'::regclass);


--
-- Name: bookwyrm_groupmemberinvitation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_groupmemberinvitation ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_groupmemberinvitation_id_seq'::regclass);


--
-- Name: bookwyrm_hashtag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_hashtag ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_hashtag_id_seq'::regclass);


--
-- Name: bookwyrm_image id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_image ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_attachment_id_seq'::regclass);


--
-- Name: bookwyrm_importitem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_importitem ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_importitem_id_seq'::regclass);


--
-- Name: bookwyrm_importjob id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_importjob ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_importjob_id_seq'::regclass);


--
-- Name: bookwyrm_inviterequest id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_inviterequest ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_inviterequest_id_seq'::regclass);


--
-- Name: bookwyrm_ipblocklist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_ipblocklist ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_ipblocklist_id_seq'::regclass);


--
-- Name: bookwyrm_keypair id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_keypair ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_keypair_id_seq'::regclass);


--
-- Name: bookwyrm_link id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_link ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_link_id_seq'::regclass);


--
-- Name: bookwyrm_linkdomain id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_linkdomain ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_linkdomain_id_seq'::regclass);


--
-- Name: bookwyrm_list id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_list ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_list_id_seq'::regclass);


--
-- Name: bookwyrm_listitem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_listitem_id_seq'::regclass);


--
-- Name: bookwyrm_listitem_endorsement id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem_endorsement ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_listitem_endorsement_id_seq'::regclass);


--
-- Name: bookwyrm_notification id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_notification_id_seq'::regclass);


--
-- Name: bookwyrm_notification_related_link_domains id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_link_domains ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_notification_related_link_domains_id_seq'::regclass);


--
-- Name: bookwyrm_notification_related_list_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_list_items ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_notification_related_list_items_id_seq'::regclass);


--
-- Name: bookwyrm_notification_related_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_reports ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_notification_related_reports_id_seq'::regclass);


--
-- Name: bookwyrm_notification_related_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_users ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_notification_related_users_id_seq'::regclass);


--
-- Name: bookwyrm_passwordreset id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_passwordreset ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_passwordreset_id_seq'::regclass);


--
-- Name: bookwyrm_progressupdate id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_progressupdate ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_progressupdate_id_seq'::regclass);


--
-- Name: bookwyrm_readthrough id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_readthrough ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_readthrough_id_seq'::regclass);


--
-- Name: bookwyrm_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_report ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_report_id_seq'::regclass);


--
-- Name: bookwyrm_report_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_report_links ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_report_links_id_seq'::regclass);


--
-- Name: bookwyrm_reportcomment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_reportcomment ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_reportcomment_id_seq'::regclass);


--
-- Name: bookwyrm_shelf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_shelf ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_shelf_id_seq'::regclass);


--
-- Name: bookwyrm_shelfbook id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_shelfbook ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_shelfbook_id_seq'::regclass);


--
-- Name: bookwyrm_siteinvite id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_siteinvite ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_siteinvite_id_seq'::regclass);


--
-- Name: bookwyrm_siteinvite_invitees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_siteinvite_invitees ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_siteinvite_invitees_id_seq'::regclass);


--
-- Name: bookwyrm_sitesettings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_sitesettings ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_sitesettings_id_seq'::regclass);


--
-- Name: bookwyrm_status id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_status_id_seq'::regclass);


--
-- Name: bookwyrm_status_mention_books id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_books ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_status_mention_books_id_seq'::regclass);


--
-- Name: bookwyrm_status_mention_hashtags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_hashtags ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_status_mention_hashtags_id_seq'::regclass);


--
-- Name: bookwyrm_status_mention_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_users ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_status_mention_users_id_seq'::regclass);


--
-- Name: bookwyrm_theme id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_theme ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_theme_id_seq'::regclass);


--
-- Name: bookwyrm_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_user_id_seq'::regclass);


--
-- Name: bookwyrm_user_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_groups ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_user_groups_id_seq'::regclass);


--
-- Name: bookwyrm_user_saved_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_saved_lists ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_user_saved_lists_id_seq'::regclass);


--
-- Name: bookwyrm_user_user_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_user_user_permissions_id_seq'::regclass);


--
-- Name: bookwyrm_userblocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userblocks ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_userblocks_id_seq'::regclass);


--
-- Name: bookwyrm_userfollowrequest id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userfollowrequest ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_userfollowrequest_id_seq'::regclass);


--
-- Name: bookwyrm_userfollows id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userfollows ALTER COLUMN id SET DEFAULT nextval('public.bookwyrm_userfollows_id_seq'::regclass);


--
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- Name: django_celery_beat_clockedschedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_clockedschedule ALTER COLUMN id SET DEFAULT nextval('public.django_celery_beat_clockedschedule_id_seq'::regclass);


--
-- Name: django_celery_beat_crontabschedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_crontabschedule ALTER COLUMN id SET DEFAULT nextval('public.django_celery_beat_crontabschedule_id_seq'::regclass);


--
-- Name: django_celery_beat_intervalschedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_intervalschedule ALTER COLUMN id SET DEFAULT nextval('public.django_celery_beat_intervalschedule_id_seq'::regclass);


--
-- Name: django_celery_beat_periodictask id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_periodictask ALTER COLUMN id SET DEFAULT nextval('public.django_celery_beat_periodictask_id_seq'::regclass);


--
-- Name: django_celery_beat_solarschedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_solarschedule ALTER COLUMN id SET DEFAULT nextval('public.django_celery_beat_solarschedule_id_seq'::regclass);


--
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_announcement bookwyrm_announcement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_announcement
    ADD CONSTRAINT bookwyrm_announcement_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_annualgoal bookwyrm_annualgoal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_annualgoal
    ADD CONSTRAINT bookwyrm_annualgoal_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_annualgoal bookwyrm_annualgoal_user_id_year_b5c6c263_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_annualgoal
    ADD CONSTRAINT bookwyrm_annualgoal_user_id_year_b5c6c263_uniq UNIQUE (user_id, year);


--
-- Name: bookwyrm_image bookwyrm_attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_image
    ADD CONSTRAINT bookwyrm_attachment_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_author bookwyrm_author_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_author
    ADD CONSTRAINT bookwyrm_author_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_automod bookwyrm_automod_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_automod
    ADD CONSTRAINT bookwyrm_automod_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_automod bookwyrm_automod_string_match_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_automod
    ADD CONSTRAINT bookwyrm_automod_string_match_key UNIQUE (string_match);


--
-- Name: bookwyrm_book_authors bookwyrm_book_authors_book_id_author_id_2bf82287_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_book_authors
    ADD CONSTRAINT bookwyrm_book_authors_book_id_author_id_2bf82287_uniq UNIQUE (book_id, author_id);


--
-- Name: bookwyrm_book_authors bookwyrm_book_authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_book_authors
    ADD CONSTRAINT bookwyrm_book_authors_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_book bookwyrm_book_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_book
    ADD CONSTRAINT bookwyrm_book_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_boost bookwyrm_boost_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_boost
    ADD CONSTRAINT bookwyrm_boost_pkey PRIMARY KEY (status_ptr_id);


--
-- Name: bookwyrm_comment bookwyrm_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_comment
    ADD CONSTRAINT bookwyrm_comment_pkey PRIMARY KEY (status_ptr_id);


--
-- Name: bookwyrm_connector bookwyrm_connector_identifier_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_connector
    ADD CONSTRAINT bookwyrm_connector_identifier_key UNIQUE (identifier);


--
-- Name: bookwyrm_connector bookwyrm_connector_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_connector
    ADD CONSTRAINT bookwyrm_connector_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_edition bookwyrm_edition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_edition
    ADD CONSTRAINT bookwyrm_edition_pkey PRIMARY KEY (book_ptr_id);


--
-- Name: bookwyrm_emailblocklist bookwyrm_emailblocklist_domain_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_emailblocklist
    ADD CONSTRAINT bookwyrm_emailblocklist_domain_key UNIQUE (domain);


--
-- Name: bookwyrm_emailblocklist bookwyrm_emailblocklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_emailblocklist
    ADD CONSTRAINT bookwyrm_emailblocklist_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_favorite bookwyrm_favorite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_favorite
    ADD CONSTRAINT bookwyrm_favorite_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_favorite bookwyrm_favorite_user_id_status_id_c230a918_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_favorite
    ADD CONSTRAINT bookwyrm_favorite_user_id_status_id_c230a918_uniq UNIQUE (user_id, status_id);


--
-- Name: bookwyrm_federatedserver bookwyrm_federatedserver_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_federatedserver
    ADD CONSTRAINT bookwyrm_federatedserver_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_federatedserver bookwyrm_federatedserver_server_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_federatedserver
    ADD CONSTRAINT bookwyrm_federatedserver_server_name_key UNIQUE (server_name);


--
-- Name: bookwyrm_filelink bookwyrm_filelink_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_filelink
    ADD CONSTRAINT bookwyrm_filelink_pkey PRIMARY KEY (link_ptr_id);


--
-- Name: bookwyrm_generatednote bookwyrm_generatedstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_generatednote
    ADD CONSTRAINT bookwyrm_generatedstatus_pkey PRIMARY KEY (status_ptr_id);


--
-- Name: bookwyrm_group bookwyrm_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_group
    ADD CONSTRAINT bookwyrm_group_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_groupmember bookwyrm_groupmember_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_groupmember
    ADD CONSTRAINT bookwyrm_groupmember_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_groupmemberinvitation bookwyrm_groupmemberinvitation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_groupmemberinvitation
    ADD CONSTRAINT bookwyrm_groupmemberinvitation_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_hashtag bookwyrm_hashtag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_hashtag
    ADD CONSTRAINT bookwyrm_hashtag_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_importitem bookwyrm_importitem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_importitem
    ADD CONSTRAINT bookwyrm_importitem_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_importjob bookwyrm_importjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_importjob
    ADD CONSTRAINT bookwyrm_importjob_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_inviterequest bookwyrm_inviterequest_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_inviterequest
    ADD CONSTRAINT bookwyrm_inviterequest_email_key UNIQUE (email);


--
-- Name: bookwyrm_inviterequest bookwyrm_inviterequest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_inviterequest
    ADD CONSTRAINT bookwyrm_inviterequest_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_ipblocklist bookwyrm_ipblocklist_address_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_ipblocklist
    ADD CONSTRAINT bookwyrm_ipblocklist_address_key UNIQUE (address);


--
-- Name: bookwyrm_ipblocklist bookwyrm_ipblocklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_ipblocklist
    ADD CONSTRAINT bookwyrm_ipblocklist_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_keypair bookwyrm_keypair_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_keypair
    ADD CONSTRAINT bookwyrm_keypair_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_link bookwyrm_link_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_link
    ADD CONSTRAINT bookwyrm_link_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_linkdomain bookwyrm_linkdomain_domain_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_linkdomain
    ADD CONSTRAINT bookwyrm_linkdomain_domain_key UNIQUE (domain);


--
-- Name: bookwyrm_linkdomain bookwyrm_linkdomain_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_linkdomain
    ADD CONSTRAINT bookwyrm_linkdomain_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_list bookwyrm_list_embed_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_list
    ADD CONSTRAINT bookwyrm_list_embed_key_key UNIQUE (embed_key);


--
-- Name: bookwyrm_list bookwyrm_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_list
    ADD CONSTRAINT bookwyrm_list_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_listitem bookwyrm_listitem_book_id_book_list_id_0693b0d1_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem
    ADD CONSTRAINT bookwyrm_listitem_book_id_book_list_id_0693b0d1_uniq UNIQUE (book_id, book_list_id);


--
-- Name: bookwyrm_listitem_endorsement bookwyrm_listitem_endorsement_listitem_id_user_id_17176b1b_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem_endorsement
    ADD CONSTRAINT bookwyrm_listitem_endorsement_listitem_id_user_id_17176b1b_uniq UNIQUE (listitem_id, user_id);


--
-- Name: bookwyrm_listitem_endorsement bookwyrm_listitem_endorsement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem_endorsement
    ADD CONSTRAINT bookwyrm_listitem_endorsement_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_listitem bookwyrm_listitem_order_book_list_id_9d1ebca7_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem
    ADD CONSTRAINT bookwyrm_listitem_order_book_list_id_9d1ebca7_uniq UNIQUE ("order", book_list_id);


--
-- Name: bookwyrm_listitem bookwyrm_listitem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem
    ADD CONSTRAINT bookwyrm_listitem_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_notification bookwyrm_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification
    ADD CONSTRAINT bookwyrm_notification_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_notification_related_link_domains bookwyrm_notification_re_notification_id_linkdoma_c3da5cd4_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_link_domains
    ADD CONSTRAINT bookwyrm_notification_re_notification_id_linkdoma_c3da5cd4_uniq UNIQUE (notification_id, linkdomain_id);


--
-- Name: bookwyrm_notification_related_list_items bookwyrm_notification_re_notification_id_listitem_95129aca_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_list_items
    ADD CONSTRAINT bookwyrm_notification_re_notification_id_listitem_95129aca_uniq UNIQUE (notification_id, listitem_id);


--
-- Name: bookwyrm_notification_related_reports bookwyrm_notification_re_notification_id_report_i_0e977212_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_reports
    ADD CONSTRAINT bookwyrm_notification_re_notification_id_report_i_0e977212_uniq UNIQUE (notification_id, report_id);


--
-- Name: bookwyrm_notification_related_users bookwyrm_notification_re_notification_id_user_id_d334828c_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_users
    ADD CONSTRAINT bookwyrm_notification_re_notification_id_user_id_d334828c_uniq UNIQUE (notification_id, user_id);


--
-- Name: bookwyrm_notification_related_link_domains bookwyrm_notification_related_link_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_link_domains
    ADD CONSTRAINT bookwyrm_notification_related_link_domains_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_notification_related_list_items bookwyrm_notification_related_list_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_list_items
    ADD CONSTRAINT bookwyrm_notification_related_list_items_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_notification_related_reports bookwyrm_notification_related_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_reports
    ADD CONSTRAINT bookwyrm_notification_related_reports_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_notification_related_users bookwyrm_notification_related_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_users
    ADD CONSTRAINT bookwyrm_notification_related_users_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_passwordreset bookwyrm_passwordreset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_passwordreset
    ADD CONSTRAINT bookwyrm_passwordreset_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_passwordreset bookwyrm_passwordreset_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_passwordreset
    ADD CONSTRAINT bookwyrm_passwordreset_user_id_key UNIQUE (user_id);


--
-- Name: bookwyrm_progressupdate bookwyrm_progressupdate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_progressupdate
    ADD CONSTRAINT bookwyrm_progressupdate_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_quotation bookwyrm_quotation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_quotation
    ADD CONSTRAINT bookwyrm_quotation_pkey PRIMARY KEY (status_ptr_id);


--
-- Name: bookwyrm_readthrough bookwyrm_readthrough_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_readthrough
    ADD CONSTRAINT bookwyrm_readthrough_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_report_links bookwyrm_report_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_report_links
    ADD CONSTRAINT bookwyrm_report_links_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_report_links bookwyrm_report_links_report_id_link_id_ec1e9c54_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_report_links
    ADD CONSTRAINT bookwyrm_report_links_report_id_link_id_ec1e9c54_uniq UNIQUE (report_id, link_id);


--
-- Name: bookwyrm_report bookwyrm_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_report
    ADD CONSTRAINT bookwyrm_report_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_reportcomment bookwyrm_reportcomment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_reportcomment
    ADD CONSTRAINT bookwyrm_reportcomment_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_review bookwyrm_review_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_review
    ADD CONSTRAINT bookwyrm_review_pkey PRIMARY KEY (status_ptr_id);


--
-- Name: bookwyrm_reviewrating bookwyrm_reviewrating_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_reviewrating
    ADD CONSTRAINT bookwyrm_reviewrating_pkey PRIMARY KEY (review_ptr_id);


--
-- Name: bookwyrm_shelf bookwyrm_shelf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_shelf
    ADD CONSTRAINT bookwyrm_shelf_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_shelf bookwyrm_shelf_user_id_identifier_5b8bcd2a_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_shelf
    ADD CONSTRAINT bookwyrm_shelf_user_id_identifier_5b8bcd2a_uniq UNIQUE (user_id, identifier);


--
-- Name: bookwyrm_shelfbook bookwyrm_shelfbook_book_id_shelf_id_7e945535_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_shelfbook
    ADD CONSTRAINT bookwyrm_shelfbook_book_id_shelf_id_7e945535_uniq UNIQUE (book_id, shelf_id);


--
-- Name: bookwyrm_shelfbook bookwyrm_shelfbook_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_shelfbook
    ADD CONSTRAINT bookwyrm_shelfbook_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_siteinvite_invitees bookwyrm_siteinvite_invi_siteinvite_id_user_id_4d9e2f50_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_siteinvite_invitees
    ADD CONSTRAINT bookwyrm_siteinvite_invi_siteinvite_id_user_id_4d9e2f50_uniq UNIQUE (siteinvite_id, user_id);


--
-- Name: bookwyrm_siteinvite_invitees bookwyrm_siteinvite_invitees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_siteinvite_invitees
    ADD CONSTRAINT bookwyrm_siteinvite_invitees_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_siteinvite bookwyrm_siteinvite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_siteinvite
    ADD CONSTRAINT bookwyrm_siteinvite_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_sitesettings bookwyrm_sitesettings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_sitesettings
    ADD CONSTRAINT bookwyrm_sitesettings_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_status_mention_hashtags bookwyrm_status_mention__status_id_hashtag_id_7a63f521_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_hashtags
    ADD CONSTRAINT bookwyrm_status_mention__status_id_hashtag_id_7a63f521_uniq UNIQUE (status_id, hashtag_id);


--
-- Name: bookwyrm_status_mention_books bookwyrm_status_mention_books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_books
    ADD CONSTRAINT bookwyrm_status_mention_books_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_status_mention_books bookwyrm_status_mention_books_status_id_book_id_369b696c_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_books
    ADD CONSTRAINT bookwyrm_status_mention_books_status_id_book_id_369b696c_uniq UNIQUE (status_id, edition_id);


--
-- Name: bookwyrm_status_mention_hashtags bookwyrm_status_mention_hashtags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_hashtags
    ADD CONSTRAINT bookwyrm_status_mention_hashtags_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_status_mention_users bookwyrm_status_mention_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_users
    ADD CONSTRAINT bookwyrm_status_mention_users_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_status_mention_users bookwyrm_status_mention_users_status_id_user_id_8184ecfd_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_users
    ADD CONSTRAINT bookwyrm_status_mention_users_status_id_user_id_8184ecfd_uniq UNIQUE (status_id, user_id);


--
-- Name: bookwyrm_status bookwyrm_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status
    ADD CONSTRAINT bookwyrm_status_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_theme bookwyrm_theme_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_theme
    ADD CONSTRAINT bookwyrm_theme_name_key UNIQUE (name);


--
-- Name: bookwyrm_theme bookwyrm_theme_path_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_theme
    ADD CONSTRAINT bookwyrm_theme_path_key UNIQUE (path);


--
-- Name: bookwyrm_theme bookwyrm_theme_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_theme
    ADD CONSTRAINT bookwyrm_theme_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_user bookwyrm_user_email_14e1f471_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_email_14e1f471_uniq UNIQUE (email);


--
-- Name: bookwyrm_user_groups bookwyrm_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_groups
    ADD CONSTRAINT bookwyrm_user_groups_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_user_groups bookwyrm_user_groups_user_id_group_id_9989e03b_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_groups
    ADD CONSTRAINT bookwyrm_user_groups_user_id_group_id_9989e03b_uniq UNIQUE (user_id, group_id);


--
-- Name: bookwyrm_user bookwyrm_user_inbox_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_inbox_key UNIQUE (inbox);


--
-- Name: bookwyrm_user bookwyrm_user_key_pair_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_key_pair_id_key UNIQUE (key_pair_id);


--
-- Name: bookwyrm_user bookwyrm_user_localname_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_localname_key UNIQUE (localname);


--
-- Name: bookwyrm_user bookwyrm_user_outbox_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_outbox_key UNIQUE (outbox);


--
-- Name: bookwyrm_user bookwyrm_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_user bookwyrm_user_remote_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_remote_id_key UNIQUE (remote_id);


--
-- Name: bookwyrm_user_saved_lists bookwyrm_user_saved_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_saved_lists
    ADD CONSTRAINT bookwyrm_user_saved_lists_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_user_saved_lists bookwyrm_user_saved_lists_user_id_list_id_d9fb8a3f_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_saved_lists
    ADD CONSTRAINT bookwyrm_user_saved_lists_user_id_list_id_d9fb8a3f_uniq UNIQUE (user_id, list_id);


--
-- Name: bookwyrm_user_user_permissions bookwyrm_user_user_permi_user_id_permission_id_e11888ba_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_user_permissions
    ADD CONSTRAINT bookwyrm_user_user_permi_user_id_permission_id_e11888ba_uniq UNIQUE (user_id, permission_id);


--
-- Name: bookwyrm_user_user_permissions bookwyrm_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_user_permissions
    ADD CONSTRAINT bookwyrm_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_user bookwyrm_user_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_username_key UNIQUE (username);


--
-- Name: bookwyrm_userblocks bookwyrm_userblocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userblocks
    ADD CONSTRAINT bookwyrm_userblocks_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_userfollowrequest bookwyrm_userfollowrequest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userfollowrequest
    ADD CONSTRAINT bookwyrm_userfollowrequest_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_userfollows bookwyrm_userfollows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userfollows
    ADD CONSTRAINT bookwyrm_userfollows_pkey PRIMARY KEY (id);


--
-- Name: bookwyrm_work bookwyrm_work_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_work
    ADD CONSTRAINT bookwyrm_work_pkey PRIMARY KEY (book_ptr_id);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_clockedschedule django_celery_beat_clockedschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_clockedschedule
    ADD CONSTRAINT django_celery_beat_clockedschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_crontabschedule django_celery_beat_crontabschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_crontabschedule
    ADD CONSTRAINT django_celery_beat_crontabschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_intervalschedule django_celery_beat_intervalschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_intervalschedule
    ADD CONSTRAINT django_celery_beat_intervalschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_periodictask django_celery_beat_periodictask_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_periodictask_name_key UNIQUE (name);


--
-- Name: django_celery_beat_periodictask django_celery_beat_periodictask_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_periodictask_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_periodictasks django_celery_beat_periodictasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_periodictasks
    ADD CONSTRAINT django_celery_beat_periodictasks_pkey PRIMARY KEY (ident);


--
-- Name: django_celery_beat_solarschedule django_celery_beat_solar_event_latitude_longitude_ba64999a_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_solarschedule
    ADD CONSTRAINT django_celery_beat_solar_event_latitude_longitude_ba64999a_uniq UNIQUE (event, latitude, longitude);


--
-- Name: django_celery_beat_solarschedule django_celery_beat_solarschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_solarschedule
    ADD CONSTRAINT django_celery_beat_solarschedule_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: bookwyrm_groupmemberinvitation unique_invitation; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_groupmemberinvitation
    ADD CONSTRAINT unique_invitation UNIQUE (group_id, user_id);


--
-- Name: bookwyrm_groupmember unique_membership; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_groupmember
    ADD CONSTRAINT unique_membership UNIQUE (group_id, user_id);


--
-- Name: bookwyrm_userblocks userblocks_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userblocks
    ADD CONSTRAINT userblocks_unique UNIQUE (user_subject_id, user_object_id);


--
-- Name: bookwyrm_userfollowrequest userfollowrequest_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userfollowrequest
    ADD CONSTRAINT userfollowrequest_unique UNIQUE (user_subject_id, user_object_id);


--
-- Name: bookwyrm_userfollows userfollows_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userfollows
    ADD CONSTRAINT userfollows_unique UNIQUE (user_subject_id, user_object_id);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: bookwyrm_announcement_user_id_1cb80317; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_announcement_user_id_1cb80317 ON public.bookwyrm_announcement USING btree (user_id);


--
-- Name: bookwyrm_annualgoal_user_id_990d313d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_annualgoal_user_id_990d313d ON public.bookwyrm_annualgoal USING btree (user_id);


--
-- Name: bookwyrm_attachment_status_id_7ee66cb7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_attachment_status_id_7ee66cb7 ON public.bookwyrm_image USING btree (status_id);


--
-- Name: bookwyrm_au_search__b050a8_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_au_search__b050a8_gin ON public.bookwyrm_author USING gin (search_vector);


--
-- Name: bookwyrm_author_last_edited_by_id_7092120c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_author_last_edited_by_id_7092120c ON public.bookwyrm_author USING btree (last_edited_by_id);


--
-- Name: bookwyrm_automod_created_by_id_f25a7c04; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_automod_created_by_id_f25a7c04 ON public.bookwyrm_automod USING btree (created_by_id);


--
-- Name: bookwyrm_automod_string_match_0bae2af5_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_automod_string_match_0bae2af5_like ON public.bookwyrm_automod USING btree (string_match varchar_pattern_ops);


--
-- Name: bookwyrm_bo_search__51beb3_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_bo_search__51beb3_gin ON public.bookwyrm_book USING gin (search_vector);


--
-- Name: bookwyrm_book_authors_author_id_979d5596; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_book_authors_author_id_979d5596 ON public.bookwyrm_book_authors USING btree (author_id);


--
-- Name: bookwyrm_book_authors_book_id_735347a7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_book_authors_book_id_735347a7 ON public.bookwyrm_book_authors USING btree (book_id);


--
-- Name: bookwyrm_book_connector_id_8fbc0d54; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_book_connector_id_8fbc0d54 ON public.bookwyrm_book USING btree (connector_id);


--
-- Name: bookwyrm_book_last_edited_by_id_8841f3e2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_book_last_edited_by_id_8841f3e2 ON public.bookwyrm_book USING btree (last_edited_by_id);


--
-- Name: bookwyrm_book_librarything_key_c7c915b1_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_book_librarything_key_c7c915b1_like ON public.bookwyrm_book USING btree (librarything_key varchar_pattern_ops);


--
-- Name: bookwyrm_boost_boosted_status_id_c061ee40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_boost_boosted_status_id_c061ee40 ON public.bookwyrm_boost USING btree (boosted_status_id);


--
-- Name: bookwyrm_comment_book_id_084ee59b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_comment_book_id_084ee59b ON public.bookwyrm_comment USING btree (book_id);


--
-- Name: bookwyrm_connector_identifier_94a6aa1f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_connector_identifier_94a6aa1f_like ON public.bookwyrm_connector USING btree (identifier varchar_pattern_ops);


--
-- Name: bookwyrm_edition_isbn_13_e6b303cc_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_edition_isbn_13_e6b303cc_like ON public.bookwyrm_edition USING btree (isbn_13 varchar_pattern_ops);


--
-- Name: bookwyrm_edition_oclc_number_6dcc47ca_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_edition_oclc_number_6dcc47ca_like ON public.bookwyrm_edition USING btree (oclc_number varchar_pattern_ops);


--
-- Name: bookwyrm_edition_parent_work_id_b5be24fd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_edition_parent_work_id_b5be24fd ON public.bookwyrm_edition USING btree (parent_work_id);


--
-- Name: bookwyrm_emailblocklist_domain_1d9d6842_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_emailblocklist_domain_1d9d6842_like ON public.bookwyrm_emailblocklist USING btree (domain varchar_pattern_ops);


--
-- Name: bookwyrm_favorite_remote_id_a6e30847_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_favorite_remote_id_a6e30847_like ON public.bookwyrm_favorite USING btree (remote_id varchar_pattern_ops);


--
-- Name: bookwyrm_favorite_status_id_1f4dd7b7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_favorite_status_id_1f4dd7b7 ON public.bookwyrm_favorite USING btree (status_id);


--
-- Name: bookwyrm_favorite_user_id_5ed1ede5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_favorite_user_id_5ed1ede5 ON public.bookwyrm_favorite USING btree (user_id);


--
-- Name: bookwyrm_federatedserver_server_name_a4f62d09_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_federatedserver_server_name_a4f62d09_like ON public.bookwyrm_federatedserver USING btree (server_name varchar_pattern_ops);


--
-- Name: bookwyrm_filelink_book_id_1ba86f32; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_filelink_book_id_1ba86f32 ON public.bookwyrm_filelink USING btree (book_id);


--
-- Name: bookwyrm_group_user_id_006073ab; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_group_user_id_006073ab ON public.bookwyrm_group USING btree (user_id);


--
-- Name: bookwyrm_groupmember_group_id_d5ee150d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_groupmember_group_id_d5ee150d ON public.bookwyrm_groupmember USING btree (group_id);


--
-- Name: bookwyrm_groupmember_user_id_a74235e3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_groupmember_user_id_a74235e3 ON public.bookwyrm_groupmember USING btree (user_id);


--
-- Name: bookwyrm_groupmemberinvitation_group_id_46dd86f4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_groupmemberinvitation_group_id_46dd86f4 ON public.bookwyrm_groupmemberinvitation USING btree (group_id);


--
-- Name: bookwyrm_groupmemberinvitation_user_id_a469bbc1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_groupmemberinvitation_user_id_a469bbc1 ON public.bookwyrm_groupmemberinvitation USING btree (user_id);


--
-- Name: bookwyrm_importitem_book_guess_id_fd681d80; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_importitem_book_guess_id_fd681d80 ON public.bookwyrm_importitem USING btree (book_guess_id);


--
-- Name: bookwyrm_importitem_book_id_afe1a268; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_importitem_book_id_afe1a268 ON public.bookwyrm_importitem USING btree (book_id);


--
-- Name: bookwyrm_importitem_job_id_02f05abd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_importitem_job_id_02f05abd ON public.bookwyrm_importitem USING btree (job_id);


--
-- Name: bookwyrm_importitem_linked_review_id_930684fa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_importitem_linked_review_id_930684fa ON public.bookwyrm_importitem USING btree (linked_review_id);


--
-- Name: bookwyrm_importjob_user_id_63ba62e3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_importjob_user_id_63ba62e3 ON public.bookwyrm_importjob USING btree (user_id);


--
-- Name: bookwyrm_inviterequest_email_5c40ea8f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_inviterequest_email_5c40ea8f_like ON public.bookwyrm_inviterequest USING btree (email varchar_pattern_ops);


--
-- Name: bookwyrm_inviterequest_invite_id_b84acf39; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_inviterequest_invite_id_b84acf39 ON public.bookwyrm_inviterequest USING btree (invite_id);


--
-- Name: bookwyrm_ipblocklist_address_99febf90_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_ipblocklist_address_99febf90_like ON public.bookwyrm_ipblocklist USING btree (address varchar_pattern_ops);


--
-- Name: bookwyrm_link_added_by_id_dbc4547e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_link_added_by_id_dbc4547e ON public.bookwyrm_link USING btree (added_by_id);


--
-- Name: bookwyrm_link_domain_id_024a20da; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_link_domain_id_024a20da ON public.bookwyrm_link USING btree (domain_id);


--
-- Name: bookwyrm_linkdomain_domain_49667597_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_linkdomain_domain_49667597_like ON public.bookwyrm_linkdomain USING btree (domain varchar_pattern_ops);


--
-- Name: bookwyrm_linkdomain_reported_by_id_df12be4d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_linkdomain_reported_by_id_df12be4d ON public.bookwyrm_linkdomain USING btree (reported_by_id);


--
-- Name: bookwyrm_list_group_id_14d749aa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_list_group_id_14d749aa ON public.bookwyrm_list USING btree (group_id);


--
-- Name: bookwyrm_list_user_id_4f06fe40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_list_user_id_4f06fe40 ON public.bookwyrm_list USING btree (user_id);


--
-- Name: bookwyrm_listitem_added_by_id_b3f6f899; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_listitem_added_by_id_b3f6f899 ON public.bookwyrm_listitem USING btree (user_id);


--
-- Name: bookwyrm_listitem_book_id_a7c27a4d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_listitem_book_id_a7c27a4d ON public.bookwyrm_listitem USING btree (book_id);


--
-- Name: bookwyrm_listitem_book_list_id_b4ab6a52; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_listitem_book_list_id_b4ab6a52 ON public.bookwyrm_listitem USING btree (book_list_id);


--
-- Name: bookwyrm_listitem_endorsement_listitem_id_5b4d6aec; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_listitem_endorsement_listitem_id_5b4d6aec ON public.bookwyrm_listitem_endorsement USING btree (listitem_id);


--
-- Name: bookwyrm_listitem_endorsement_user_id_6202f205; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_listitem_endorsement_user_id_6202f205 ON public.bookwyrm_listitem_endorsement USING btree (user_id);


--
-- Name: bookwyrm_notification_rela_linkdomain_id_dfb5e964; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_rela_linkdomain_id_dfb5e964 ON public.bookwyrm_notification_related_link_domains USING btree (linkdomain_id);


--
-- Name: bookwyrm_notification_rela_notification_id_6d736968; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_rela_notification_id_6d736968 ON public.bookwyrm_notification_related_link_domains USING btree (notification_id);


--
-- Name: bookwyrm_notification_rela_notification_id_d4941d78; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_rela_notification_id_d4941d78 ON public.bookwyrm_notification_related_list_items USING btree (notification_id);


--
-- Name: bookwyrm_notification_related_group_id_39d5337f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_related_group_id_39d5337f ON public.bookwyrm_notification USING btree (related_group_id);


--
-- Name: bookwyrm_notification_related_import_id_29d29e13; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_related_import_id_29d29e13 ON public.bookwyrm_notification USING btree (related_import_id);


--
-- Name: bookwyrm_notification_related_list_items_listitem_id_c14f76f0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_related_list_items_listitem_id_c14f76f0 ON public.bookwyrm_notification_related_list_items USING btree (listitem_id);


--
-- Name: bookwyrm_notification_related_reports_notification_id_e44582c9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_related_reports_notification_id_e44582c9 ON public.bookwyrm_notification_related_reports USING btree (notification_id);


--
-- Name: bookwyrm_notification_related_reports_report_id_a48ecefa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_related_reports_report_id_a48ecefa ON public.bookwyrm_notification_related_reports USING btree (report_id);


--
-- Name: bookwyrm_notification_related_status_id_763f939c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_related_status_id_763f939c ON public.bookwyrm_notification USING btree (related_status_id);


--
-- Name: bookwyrm_notification_related_users_notification_id_053265fe; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_related_users_notification_id_053265fe ON public.bookwyrm_notification_related_users USING btree (notification_id);


--
-- Name: bookwyrm_notification_related_users_user_id_2cb818fd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_related_users_user_id_2cb818fd ON public.bookwyrm_notification_related_users USING btree (user_id);


--
-- Name: bookwyrm_notification_user_id_5d525342; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_notification_user_id_5d525342 ON public.bookwyrm_notification USING btree (user_id);


--
-- Name: bookwyrm_progressupdate_readthrough_id_e6e34638; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_progressupdate_readthrough_id_e6e34638 ON public.bookwyrm_progressupdate USING btree (readthrough_id);


--
-- Name: bookwyrm_progressupdate_user_id_7aa0cb83; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_progressupdate_user_id_7aa0cb83 ON public.bookwyrm_progressupdate USING btree (user_id);


--
-- Name: bookwyrm_quotation_book_id_22093e34; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_quotation_book_id_22093e34 ON public.bookwyrm_quotation USING btree (book_id);


--
-- Name: bookwyrm_readthrough_book_id_2709f9a5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_readthrough_book_id_2709f9a5 ON public.bookwyrm_readthrough USING btree (book_id);


--
-- Name: bookwyrm_readthrough_user_id_cdc1934b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_readthrough_user_id_cdc1934b ON public.bookwyrm_readthrough USING btree (user_id);


--
-- Name: bookwyrm_report_links_link_id_6f11d60f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_report_links_link_id_6f11d60f ON public.bookwyrm_report_links USING btree (link_id);


--
-- Name: bookwyrm_report_links_report_id_b25fc119; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_report_links_report_id_b25fc119 ON public.bookwyrm_report_links USING btree (report_id);


--
-- Name: bookwyrm_report_reporter_id_c164ed90; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_report_reporter_id_c164ed90 ON public.bookwyrm_report USING btree (reporter_id);


--
-- Name: bookwyrm_report_status_id_1c875eee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_report_status_id_1c875eee ON public.bookwyrm_report USING btree (status_id);


--
-- Name: bookwyrm_report_user_id_c6da8b99; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_report_user_id_c6da8b99 ON public.bookwyrm_report USING btree (user_id);


--
-- Name: bookwyrm_reportcomment_report_id_72725a14; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_reportcomment_report_id_72725a14 ON public.bookwyrm_reportcomment USING btree (report_id);


--
-- Name: bookwyrm_reportcomment_user_id_03e2ea73; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_reportcomment_user_id_03e2ea73 ON public.bookwyrm_reportcomment USING btree (user_id);


--
-- Name: bookwyrm_review_book_id_26b3aead; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_review_book_id_26b3aead ON public.bookwyrm_review USING btree (book_id);


--
-- Name: bookwyrm_shelf_user_id_cb8d2889; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_shelf_user_id_cb8d2889 ON public.bookwyrm_shelf USING btree (user_id);


--
-- Name: bookwyrm_shelfbook_added_by_id_46586428; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_shelfbook_added_by_id_46586428 ON public.bookwyrm_shelfbook USING btree (user_id);


--
-- Name: bookwyrm_shelfbook_book_id_c04724de; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_shelfbook_book_id_c04724de ON public.bookwyrm_shelfbook USING btree (book_id);


--
-- Name: bookwyrm_shelfbook_shelf_id_30ee4fe8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_shelfbook_shelf_id_30ee4fe8 ON public.bookwyrm_shelfbook USING btree (shelf_id);


--
-- Name: bookwyrm_siteinvite_invitees_siteinvite_id_497ae949; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_siteinvite_invitees_siteinvite_id_497ae949 ON public.bookwyrm_siteinvite_invitees USING btree (siteinvite_id);


--
-- Name: bookwyrm_siteinvite_invitees_user_id_6872ebd4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_siteinvite_invitees_user_id_6872ebd4 ON public.bookwyrm_siteinvite_invitees USING btree (user_id);


--
-- Name: bookwyrm_siteinvite_user_id_36545fa0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_siteinvite_user_id_36545fa0 ON public.bookwyrm_siteinvite USING btree (user_id);


--
-- Name: bookwyrm_sitesettings_default_theme_id_680d648c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_sitesettings_default_theme_id_680d648c ON public.bookwyrm_sitesettings USING btree (default_theme_id);


--
-- Name: bookwyrm_sitesettings_default_user_auth_group_id_1cd41dec; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_sitesettings_default_user_auth_group_id_1cd41dec ON public.bookwyrm_sitesettings USING btree (default_user_auth_group_id);


--
-- Name: bookwyrm_status_mention_books_book_id_406d00a9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_status_mention_books_book_id_406d00a9 ON public.bookwyrm_status_mention_books USING btree (edition_id);


--
-- Name: bookwyrm_status_mention_books_status_id_7b542958; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_status_mention_books_status_id_7b542958 ON public.bookwyrm_status_mention_books USING btree (status_id);


--
-- Name: bookwyrm_status_mention_hashtags_hashtag_id_a2202e05; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_status_mention_hashtags_hashtag_id_a2202e05 ON public.bookwyrm_status_mention_hashtags USING btree (hashtag_id);


--
-- Name: bookwyrm_status_mention_hashtags_status_id_d5d54f76; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_status_mention_hashtags_status_id_d5d54f76 ON public.bookwyrm_status_mention_hashtags USING btree (status_id);


--
-- Name: bookwyrm_status_mention_users_status_id_01acc86b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_status_mention_users_status_id_01acc86b ON public.bookwyrm_status_mention_users USING btree (status_id);


--
-- Name: bookwyrm_status_mention_users_user_id_7a5496e2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_status_mention_users_user_id_7a5496e2 ON public.bookwyrm_status_mention_users USING btree (user_id);


--
-- Name: bookwyrm_status_remote_id_34463c0f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_status_remote_id_34463c0f_like ON public.bookwyrm_status USING btree (remote_id varchar_pattern_ops);


--
-- Name: bookwyrm_status_reply_parent_id_dcdefaee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_status_reply_parent_id_dcdefaee ON public.bookwyrm_status USING btree (reply_parent_id);


--
-- Name: bookwyrm_status_user_id_b343e19b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_status_user_id_b343e19b ON public.bookwyrm_status USING btree (user_id);


--
-- Name: bookwyrm_theme_name_a3820df3_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_theme_name_a3820df3_like ON public.bookwyrm_theme USING btree (name varchar_pattern_ops);


--
-- Name: bookwyrm_theme_path_b3c4105c_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_theme_path_b3c4105c_like ON public.bookwyrm_theme USING btree (path varchar_pattern_ops);


--
-- Name: bookwyrm_user_email_14e1f471_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_email_14e1f471_like ON public.bookwyrm_user USING btree (email varchar_pattern_ops);


--
-- Name: bookwyrm_user_federated_server_id_97177f4f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_federated_server_id_97177f4f ON public.bookwyrm_user USING btree (federated_server_id);


--
-- Name: bookwyrm_user_groups_group_id_ab13e46b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_groups_group_id_ab13e46b ON public.bookwyrm_user_groups USING btree (group_id);


--
-- Name: bookwyrm_user_groups_user_id_595ce39d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_groups_user_id_595ce39d ON public.bookwyrm_user_groups USING btree (user_id);


--
-- Name: bookwyrm_user_inbox_9d6236a4_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_inbox_9d6236a4_like ON public.bookwyrm_user USING btree (inbox varchar_pattern_ops);


--
-- Name: bookwyrm_user_outbox_359bdd20_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_outbox_359bdd20_like ON public.bookwyrm_user USING btree (outbox varchar_pattern_ops);


--
-- Name: bookwyrm_user_remote_id_4edd87e1_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_remote_id_4edd87e1_like ON public.bookwyrm_user USING btree (remote_id varchar_pattern_ops);


--
-- Name: bookwyrm_user_saved_lists_list_id_ccfe32c8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_saved_lists_list_id_ccfe32c8 ON public.bookwyrm_user_saved_lists USING btree (list_id);


--
-- Name: bookwyrm_user_saved_lists_user_id_e0066a9e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_saved_lists_user_id_e0066a9e ON public.bookwyrm_user_saved_lists USING btree (user_id);


--
-- Name: bookwyrm_user_theme_id_bbaa5748; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_theme_id_bbaa5748 ON public.bookwyrm_user USING btree (theme_id);


--
-- Name: bookwyrm_user_user_permissions_permission_id_3f309e47; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_user_permissions_permission_id_3f309e47 ON public.bookwyrm_user_user_permissions USING btree (permission_id);


--
-- Name: bookwyrm_user_user_permissions_user_id_a14bcdd0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_user_permissions_user_id_a14bcdd0 ON public.bookwyrm_user_user_permissions USING btree (user_id);


--
-- Name: bookwyrm_user_username_8c7653a6_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_user_username_8c7653a6_like ON public.bookwyrm_user USING btree (username varchar_pattern_ops);


--
-- Name: bookwyrm_userblocks_user_object_id_ff33ba18; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_userblocks_user_object_id_ff33ba18 ON public.bookwyrm_userblocks USING btree (user_object_id);


--
-- Name: bookwyrm_userblocks_user_subject_id_52f9bc38; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_userblocks_user_subject_id_52f9bc38 ON public.bookwyrm_userblocks USING btree (user_subject_id);


--
-- Name: bookwyrm_userfollowrequest_user_object_id_7260db31; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_userfollowrequest_user_object_id_7260db31 ON public.bookwyrm_userfollowrequest USING btree (user_object_id);


--
-- Name: bookwyrm_userfollowrequest_user_subject_id_6a03a52e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_userfollowrequest_user_subject_id_6a03a52e ON public.bookwyrm_userfollowrequest USING btree (user_subject_id);


--
-- Name: bookwyrm_userfollows_user_object_id_01314278; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_userfollows_user_object_id_01314278 ON public.bookwyrm_userfollows USING btree (user_object_id);


--
-- Name: bookwyrm_userfollows_user_subject_id_8f86563d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_userfollows_user_subject_id_8f86563d ON public.bookwyrm_userfollows USING btree (user_subject_id);


--
-- Name: bookwyrm_work_lccn_bbcc8386_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookwyrm_work_lccn_bbcc8386_like ON public.bookwyrm_work USING btree (lccn varchar_pattern_ops);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_celery_beat_periodictask_clocked_id_47a69f82; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_celery_beat_periodictask_clocked_id_47a69f82 ON public.django_celery_beat_periodictask USING btree (clocked_id);


--
-- Name: django_celery_beat_periodictask_crontab_id_d3cba168; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_celery_beat_periodictask_crontab_id_d3cba168 ON public.django_celery_beat_periodictask USING btree (crontab_id);


--
-- Name: django_celery_beat_periodictask_interval_id_a8ca27da; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_celery_beat_periodictask_interval_id_a8ca27da ON public.django_celery_beat_periodictask USING btree (interval_id);


--
-- Name: django_celery_beat_periodictask_name_265a36b7_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_celery_beat_periodictask_name_265a36b7_like ON public.django_celery_beat_periodictask USING btree (name varchar_pattern_ops);


--
-- Name: django_celery_beat_periodictask_solar_id_a87ce72c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_celery_beat_periodictask_solar_id_a87ce72c ON public.django_celery_beat_periodictask USING btree (solar_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: bookwyrm_author author_search_vector_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER author_search_vector_trigger AFTER UPDATE OF name ON public.bookwyrm_author FOR EACH ROW EXECUTE FUNCTION public.author_trigger();


--
-- Name: bookwyrm_book_authors book_authors_search_vector_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER book_authors_search_vector_trigger AFTER INSERT OR DELETE ON public.bookwyrm_book_authors FOR EACH ROW EXECUTE FUNCTION public.book_authors_trigger();


--
-- Name: bookwyrm_book search_vector_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER search_vector_trigger BEFORE INSERT OR UPDATE OF title, subtitle, series, search_vector ON public.bookwyrm_book FOR EACH ROW EXECUTE FUNCTION public.book_trigger();


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_announcement bookwyrm_announcement_user_id_1cb80317_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_announcement
    ADD CONSTRAINT bookwyrm_announcement_user_id_1cb80317_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_annualgoal bookwyrm_annualgoal_user_id_990d313d_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_annualgoal
    ADD CONSTRAINT bookwyrm_annualgoal_user_id_990d313d_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_author bookwyrm_author_last_edited_by_id_7092120c_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_author
    ADD CONSTRAINT bookwyrm_author_last_edited_by_id_7092120c_fk_bookwyrm_user_id FOREIGN KEY (last_edited_by_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_automod bookwyrm_automod_created_by_id_f25a7c04_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_automod
    ADD CONSTRAINT bookwyrm_automod_created_by_id_f25a7c04_fk_bookwyrm_user_id FOREIGN KEY (created_by_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_book_authors bookwyrm_book_authors_author_id_979d5596_fk_bookwyrm_author_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_book_authors
    ADD CONSTRAINT bookwyrm_book_authors_author_id_979d5596_fk_bookwyrm_author_id FOREIGN KEY (author_id) REFERENCES public.bookwyrm_author(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_book_authors bookwyrm_book_authors_book_id_735347a7_fk_bookwyrm_book_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_book_authors
    ADD CONSTRAINT bookwyrm_book_authors_book_id_735347a7_fk_bookwyrm_book_id FOREIGN KEY (book_id) REFERENCES public.bookwyrm_book(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_book bookwyrm_book_connector_id_8fbc0d54_fk_bookwyrm_connector_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_book
    ADD CONSTRAINT bookwyrm_book_connector_id_8fbc0d54_fk_bookwyrm_connector_id FOREIGN KEY (connector_id) REFERENCES public.bookwyrm_connector(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_book bookwyrm_book_last_edited_by_id_8841f3e2_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_book
    ADD CONSTRAINT bookwyrm_book_last_edited_by_id_8841f3e2_fk_bookwyrm_user_id FOREIGN KEY (last_edited_by_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_boost bookwyrm_boost_boosted_status_id_c061ee40_fk_bookwyrm_status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_boost
    ADD CONSTRAINT bookwyrm_boost_boosted_status_id_c061ee40_fk_bookwyrm_status_id FOREIGN KEY (boosted_status_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_boost bookwyrm_boost_status_ptr_id_c30c3d1b_fk_bookwyrm_status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_boost
    ADD CONSTRAINT bookwyrm_boost_status_ptr_id_c30c3d1b_fk_bookwyrm_status_id FOREIGN KEY (status_ptr_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_comment bookwyrm_comment_book_id_084ee59b_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_comment
    ADD CONSTRAINT bookwyrm_comment_book_id_084ee59b_fk_bookwyrm_ FOREIGN KEY (book_id) REFERENCES public.bookwyrm_edition(book_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_comment bookwyrm_comment_status_ptr_id_4e66bea8_fk_bookwyrm_status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_comment
    ADD CONSTRAINT bookwyrm_comment_status_ptr_id_4e66bea8_fk_bookwyrm_status_id FOREIGN KEY (status_ptr_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_edition bookwyrm_edition_book_ptr_id_4b0d5e19_fk_bookwyrm_book_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_edition
    ADD CONSTRAINT bookwyrm_edition_book_ptr_id_4b0d5e19_fk_bookwyrm_book_id FOREIGN KEY (book_ptr_id) REFERENCES public.bookwyrm_book(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_edition bookwyrm_edition_parent_work_id_b5be24fd_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_edition
    ADD CONSTRAINT bookwyrm_edition_parent_work_id_b5be24fd_fk_bookwyrm_ FOREIGN KEY (parent_work_id) REFERENCES public.bookwyrm_work(book_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_favorite bookwyrm_favorite_status_id_1f4dd7b7_fk_bookwyrm_status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_favorite
    ADD CONSTRAINT bookwyrm_favorite_status_id_1f4dd7b7_fk_bookwyrm_status_id FOREIGN KEY (status_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_favorite bookwyrm_favorite_user_id_5ed1ede5_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_favorite
    ADD CONSTRAINT bookwyrm_favorite_user_id_5ed1ede5_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_filelink bookwyrm_filelink_book_id_1ba86f32_fk_bookwyrm_book_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_filelink
    ADD CONSTRAINT bookwyrm_filelink_book_id_1ba86f32_fk_bookwyrm_book_id FOREIGN KEY (book_id) REFERENCES public.bookwyrm_book(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_filelink bookwyrm_filelink_link_ptr_id_37759294_fk_bookwyrm_link_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_filelink
    ADD CONSTRAINT bookwyrm_filelink_link_ptr_id_37759294_fk_bookwyrm_link_id FOREIGN KEY (link_ptr_id) REFERENCES public.bookwyrm_link(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_generatednote bookwyrm_generatedno_status_ptr_id_f4bc953b_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_generatednote
    ADD CONSTRAINT bookwyrm_generatedno_status_ptr_id_f4bc953b_fk_bookwyrm_ FOREIGN KEY (status_ptr_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_group bookwyrm_group_user_id_006073ab_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_group
    ADD CONSTRAINT bookwyrm_group_user_id_006073ab_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_groupmemberinvitation bookwyrm_groupmember_group_id_46dd86f4_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_groupmemberinvitation
    ADD CONSTRAINT bookwyrm_groupmember_group_id_46dd86f4_fk_bookwyrm_ FOREIGN KEY (group_id) REFERENCES public.bookwyrm_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_groupmember bookwyrm_groupmember_group_id_d5ee150d_fk_bookwyrm_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_groupmember
    ADD CONSTRAINT bookwyrm_groupmember_group_id_d5ee150d_fk_bookwyrm_group_id FOREIGN KEY (group_id) REFERENCES public.bookwyrm_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_groupmemberinvitation bookwyrm_groupmember_user_id_a469bbc1_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_groupmemberinvitation
    ADD CONSTRAINT bookwyrm_groupmember_user_id_a469bbc1_fk_bookwyrm_ FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_groupmember bookwyrm_groupmember_user_id_a74235e3_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_groupmember
    ADD CONSTRAINT bookwyrm_groupmember_user_id_a74235e3_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_image bookwyrm_image_status_id_606d4538_fk_bookwyrm_status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_image
    ADD CONSTRAINT bookwyrm_image_status_id_606d4538_fk_bookwyrm_status_id FOREIGN KEY (status_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_importitem bookwyrm_importitem_book_guess_id_fd681d80_fk_bookwyrm_book_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_importitem
    ADD CONSTRAINT bookwyrm_importitem_book_guess_id_fd681d80_fk_bookwyrm_book_id FOREIGN KEY (book_guess_id) REFERENCES public.bookwyrm_book(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_importitem bookwyrm_importitem_book_id_afe1a268_fk_bookwyrm_book_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_importitem
    ADD CONSTRAINT bookwyrm_importitem_book_id_afe1a268_fk_bookwyrm_book_id FOREIGN KEY (book_id) REFERENCES public.bookwyrm_book(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_importitem bookwyrm_importitem_job_id_02f05abd_fk_bookwyrm_importjob_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_importitem
    ADD CONSTRAINT bookwyrm_importitem_job_id_02f05abd_fk_bookwyrm_importjob_id FOREIGN KEY (job_id) REFERENCES public.bookwyrm_importjob(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_importitem bookwyrm_importitem_linked_review_id_930684fa_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_importitem
    ADD CONSTRAINT bookwyrm_importitem_linked_review_id_930684fa_fk_bookwyrm_ FOREIGN KEY (linked_review_id) REFERENCES public.bookwyrm_review(status_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_importjob bookwyrm_importjob_user_id_63ba62e3_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_importjob
    ADD CONSTRAINT bookwyrm_importjob_user_id_63ba62e3_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_inviterequest bookwyrm_invitereque_invite_id_b84acf39_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_inviterequest
    ADD CONSTRAINT bookwyrm_invitereque_invite_id_b84acf39_fk_bookwyrm_ FOREIGN KEY (invite_id) REFERENCES public.bookwyrm_siteinvite(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_link bookwyrm_link_added_by_id_dbc4547e_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_link
    ADD CONSTRAINT bookwyrm_link_added_by_id_dbc4547e_fk_bookwyrm_user_id FOREIGN KEY (added_by_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_link bookwyrm_link_domain_id_024a20da_fk_bookwyrm_linkdomain_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_link
    ADD CONSTRAINT bookwyrm_link_domain_id_024a20da_fk_bookwyrm_linkdomain_id FOREIGN KEY (domain_id) REFERENCES public.bookwyrm_linkdomain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_linkdomain bookwyrm_linkdomain_reported_by_id_df12be4d_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_linkdomain
    ADD CONSTRAINT bookwyrm_linkdomain_reported_by_id_df12be4d_fk_bookwyrm_user_id FOREIGN KEY (reported_by_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_list bookwyrm_list_group_id_14d749aa_fk_bookwyrm_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_list
    ADD CONSTRAINT bookwyrm_list_group_id_14d749aa_fk_bookwyrm_group_id FOREIGN KEY (group_id) REFERENCES public.bookwyrm_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_list bookwyrm_list_user_id_4f06fe40_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_list
    ADD CONSTRAINT bookwyrm_list_user_id_4f06fe40_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_listitem bookwyrm_listitem_book_id_a7c27a4d_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem
    ADD CONSTRAINT bookwyrm_listitem_book_id_a7c27a4d_fk_bookwyrm_ FOREIGN KEY (book_id) REFERENCES public.bookwyrm_edition(book_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_listitem bookwyrm_listitem_book_list_id_b4ab6a52_fk_bookwyrm_list_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem
    ADD CONSTRAINT bookwyrm_listitem_book_list_id_b4ab6a52_fk_bookwyrm_list_id FOREIGN KEY (book_list_id) REFERENCES public.bookwyrm_list(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_listitem_endorsement bookwyrm_listitem_en_listitem_id_5b4d6aec_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem_endorsement
    ADD CONSTRAINT bookwyrm_listitem_en_listitem_id_5b4d6aec_fk_bookwyrm_ FOREIGN KEY (listitem_id) REFERENCES public.bookwyrm_listitem(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_listitem_endorsement bookwyrm_listitem_en_user_id_6202f205_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem_endorsement
    ADD CONSTRAINT bookwyrm_listitem_en_user_id_6202f205_fk_bookwyrm_ FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_listitem bookwyrm_listitem_user_id_102fa487_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_listitem
    ADD CONSTRAINT bookwyrm_listitem_user_id_102fa487_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification_related_link_domains bookwyrm_notificatio_linkdomain_id_dfb5e964_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_link_domains
    ADD CONSTRAINT bookwyrm_notificatio_linkdomain_id_dfb5e964_fk_bookwyrm_ FOREIGN KEY (linkdomain_id) REFERENCES public.bookwyrm_linkdomain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification_related_list_items bookwyrm_notificatio_listitem_id_c14f76f0_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_list_items
    ADD CONSTRAINT bookwyrm_notificatio_listitem_id_c14f76f0_fk_bookwyrm_ FOREIGN KEY (listitem_id) REFERENCES public.bookwyrm_listitem(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification_related_users bookwyrm_notificatio_notification_id_053265fe_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_users
    ADD CONSTRAINT bookwyrm_notificatio_notification_id_053265fe_fk_bookwyrm_ FOREIGN KEY (notification_id) REFERENCES public.bookwyrm_notification(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification_related_link_domains bookwyrm_notificatio_notification_id_6d736968_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_link_domains
    ADD CONSTRAINT bookwyrm_notificatio_notification_id_6d736968_fk_bookwyrm_ FOREIGN KEY (notification_id) REFERENCES public.bookwyrm_notification(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification_related_list_items bookwyrm_notificatio_notification_id_d4941d78_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_list_items
    ADD CONSTRAINT bookwyrm_notificatio_notification_id_d4941d78_fk_bookwyrm_ FOREIGN KEY (notification_id) REFERENCES public.bookwyrm_notification(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification_related_reports bookwyrm_notificatio_notification_id_e44582c9_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_reports
    ADD CONSTRAINT bookwyrm_notificatio_notification_id_e44582c9_fk_bookwyrm_ FOREIGN KEY (notification_id) REFERENCES public.bookwyrm_notification(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification bookwyrm_notificatio_related_group_id_39d5337f_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification
    ADD CONSTRAINT bookwyrm_notificatio_related_group_id_39d5337f_fk_bookwyrm_ FOREIGN KEY (related_group_id) REFERENCES public.bookwyrm_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification bookwyrm_notificatio_related_import_id_29d29e13_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification
    ADD CONSTRAINT bookwyrm_notificatio_related_import_id_29d29e13_fk_bookwyrm_ FOREIGN KEY (related_import_id) REFERENCES public.bookwyrm_importjob(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification bookwyrm_notificatio_related_status_id_763f939c_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification
    ADD CONSTRAINT bookwyrm_notificatio_related_status_id_763f939c_fk_bookwyrm_ FOREIGN KEY (related_status_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification_related_reports bookwyrm_notificatio_report_id_a48ecefa_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_reports
    ADD CONSTRAINT bookwyrm_notificatio_report_id_a48ecefa_fk_bookwyrm_ FOREIGN KEY (report_id) REFERENCES public.bookwyrm_report(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification_related_users bookwyrm_notificatio_user_id_2cb818fd_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification_related_users
    ADD CONSTRAINT bookwyrm_notificatio_user_id_2cb818fd_fk_bookwyrm_ FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_notification bookwyrm_notification_user_id_5d525342_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_notification
    ADD CONSTRAINT bookwyrm_notification_user_id_5d525342_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_passwordreset bookwyrm_passwordreset_user_id_ecf9c5f7_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_passwordreset
    ADD CONSTRAINT bookwyrm_passwordreset_user_id_ecf9c5f7_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_progressupdate bookwyrm_progressupd_readthrough_id_e6e34638_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_progressupdate
    ADD CONSTRAINT bookwyrm_progressupd_readthrough_id_e6e34638_fk_bookwyrm_ FOREIGN KEY (readthrough_id) REFERENCES public.bookwyrm_readthrough(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_progressupdate bookwyrm_progressupdate_user_id_7aa0cb83_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_progressupdate
    ADD CONSTRAINT bookwyrm_progressupdate_user_id_7aa0cb83_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_quotation bookwyrm_quotation_book_id_22093e34_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_quotation
    ADD CONSTRAINT bookwyrm_quotation_book_id_22093e34_fk_bookwyrm_ FOREIGN KEY (book_id) REFERENCES public.bookwyrm_edition(book_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_quotation bookwyrm_quotation_status_ptr_id_afa00eab_fk_bookwyrm_status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_quotation
    ADD CONSTRAINT bookwyrm_quotation_status_ptr_id_afa00eab_fk_bookwyrm_status_id FOREIGN KEY (status_ptr_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_readthrough bookwyrm_readthrough_book_id_2709f9a5_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_readthrough
    ADD CONSTRAINT bookwyrm_readthrough_book_id_2709f9a5_fk_bookwyrm_ FOREIGN KEY (book_id) REFERENCES public.bookwyrm_edition(book_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_readthrough bookwyrm_readthrough_user_id_cdc1934b_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_readthrough
    ADD CONSTRAINT bookwyrm_readthrough_user_id_cdc1934b_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_report_links bookwyrm_report_links_link_id_6f11d60f_fk_bookwyrm_link_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_report_links
    ADD CONSTRAINT bookwyrm_report_links_link_id_6f11d60f_fk_bookwyrm_link_id FOREIGN KEY (link_id) REFERENCES public.bookwyrm_link(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_report_links bookwyrm_report_links_report_id_b25fc119_fk_bookwyrm_report_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_report_links
    ADD CONSTRAINT bookwyrm_report_links_report_id_b25fc119_fk_bookwyrm_report_id FOREIGN KEY (report_id) REFERENCES public.bookwyrm_report(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_report bookwyrm_report_reporter_id_c164ed90_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_report
    ADD CONSTRAINT bookwyrm_report_reporter_id_c164ed90_fk_bookwyrm_user_id FOREIGN KEY (reporter_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_report bookwyrm_report_status_id_1c875eee_fk_bookwyrm_status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_report
    ADD CONSTRAINT bookwyrm_report_status_id_1c875eee_fk_bookwyrm_status_id FOREIGN KEY (status_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_report bookwyrm_report_user_id_c6da8b99_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_report
    ADD CONSTRAINT bookwyrm_report_user_id_c6da8b99_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_reportcomment bookwyrm_reportcomment_report_id_72725a14_fk_bookwyrm_report_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_reportcomment
    ADD CONSTRAINT bookwyrm_reportcomment_report_id_72725a14_fk_bookwyrm_report_id FOREIGN KEY (report_id) REFERENCES public.bookwyrm_report(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_reportcomment bookwyrm_reportcomment_user_id_03e2ea73_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_reportcomment
    ADD CONSTRAINT bookwyrm_reportcomment_user_id_03e2ea73_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_review bookwyrm_review_book_id_26b3aead_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_review
    ADD CONSTRAINT bookwyrm_review_book_id_26b3aead_fk_bookwyrm_ FOREIGN KEY (book_id) REFERENCES public.bookwyrm_edition(book_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_review bookwyrm_review_status_ptr_id_3447f4bf_fk_bookwyrm_status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_review
    ADD CONSTRAINT bookwyrm_review_status_ptr_id_3447f4bf_fk_bookwyrm_status_id FOREIGN KEY (status_ptr_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_reviewrating bookwyrm_reviewratin_review_ptr_id_0f64137f_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_reviewrating
    ADD CONSTRAINT bookwyrm_reviewratin_review_ptr_id_0f64137f_fk_bookwyrm_ FOREIGN KEY (review_ptr_id) REFERENCES public.bookwyrm_review(status_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_shelf bookwyrm_shelf_user_id_cb8d2889_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_shelf
    ADD CONSTRAINT bookwyrm_shelf_user_id_cb8d2889_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_shelfbook bookwyrm_shelfbook_book_id_c04724de_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_shelfbook
    ADD CONSTRAINT bookwyrm_shelfbook_book_id_c04724de_fk_bookwyrm_ FOREIGN KEY (book_id) REFERENCES public.bookwyrm_edition(book_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_shelfbook bookwyrm_shelfbook_shelf_id_30ee4fe8_fk_bookwyrm_shelf_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_shelfbook
    ADD CONSTRAINT bookwyrm_shelfbook_shelf_id_30ee4fe8_fk_bookwyrm_shelf_id FOREIGN KEY (shelf_id) REFERENCES public.bookwyrm_shelf(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_shelfbook bookwyrm_shelfbook_user_id_60796f7f_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_shelfbook
    ADD CONSTRAINT bookwyrm_shelfbook_user_id_60796f7f_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_siteinvite_invitees bookwyrm_siteinvite__siteinvite_id_497ae949_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_siteinvite_invitees
    ADD CONSTRAINT bookwyrm_siteinvite__siteinvite_id_497ae949_fk_bookwyrm_ FOREIGN KEY (siteinvite_id) REFERENCES public.bookwyrm_siteinvite(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_siteinvite_invitees bookwyrm_siteinvite__user_id_6872ebd4_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_siteinvite_invitees
    ADD CONSTRAINT bookwyrm_siteinvite__user_id_6872ebd4_fk_bookwyrm_ FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_siteinvite bookwyrm_siteinvite_user_id_36545fa0_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_siteinvite
    ADD CONSTRAINT bookwyrm_siteinvite_user_id_36545fa0_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_sitesettings bookwyrm_sitesetting_default_theme_id_680d648c_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_sitesettings
    ADD CONSTRAINT bookwyrm_sitesetting_default_theme_id_680d648c_fk_bookwyrm_ FOREIGN KEY (default_theme_id) REFERENCES public.bookwyrm_theme(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_sitesettings bookwyrm_sitesetting_default_user_auth_gr_1cd41dec_fk_auth_grou; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_sitesettings
    ADD CONSTRAINT bookwyrm_sitesetting_default_user_auth_gr_1cd41dec_fk_auth_grou FOREIGN KEY (default_user_auth_group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_status_mention_books bookwyrm_status_ment_edition_id_ace870fd_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_books
    ADD CONSTRAINT bookwyrm_status_ment_edition_id_ace870fd_fk_bookwyrm_ FOREIGN KEY (edition_id) REFERENCES public.bookwyrm_edition(book_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_status_mention_hashtags bookwyrm_status_ment_hashtag_id_a2202e05_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_hashtags
    ADD CONSTRAINT bookwyrm_status_ment_hashtag_id_a2202e05_fk_bookwyrm_ FOREIGN KEY (hashtag_id) REFERENCES public.bookwyrm_hashtag(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_status_mention_users bookwyrm_status_ment_status_id_01acc86b_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_users
    ADD CONSTRAINT bookwyrm_status_ment_status_id_01acc86b_fk_bookwyrm_ FOREIGN KEY (status_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_status_mention_books bookwyrm_status_ment_status_id_7b542958_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_books
    ADD CONSTRAINT bookwyrm_status_ment_status_id_7b542958_fk_bookwyrm_ FOREIGN KEY (status_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_status_mention_hashtags bookwyrm_status_ment_status_id_d5d54f76_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_hashtags
    ADD CONSTRAINT bookwyrm_status_ment_status_id_d5d54f76_fk_bookwyrm_ FOREIGN KEY (status_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_status_mention_users bookwyrm_status_ment_user_id_7a5496e2_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status_mention_users
    ADD CONSTRAINT bookwyrm_status_ment_user_id_7a5496e2_fk_bookwyrm_ FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_status bookwyrm_status_reply_parent_id_dcdefaee_fk_bookwyrm_status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status
    ADD CONSTRAINT bookwyrm_status_reply_parent_id_dcdefaee_fk_bookwyrm_status_id FOREIGN KEY (reply_parent_id) REFERENCES public.bookwyrm_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_status bookwyrm_status_user_id_b343e19b_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_status
    ADD CONSTRAINT bookwyrm_status_user_id_b343e19b_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_user bookwyrm_user_federated_server_id_97177f4f_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_federated_server_id_97177f4f_fk_bookwyrm_ FOREIGN KEY (federated_server_id) REFERENCES public.bookwyrm_federatedserver(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_user_groups bookwyrm_user_groups_group_id_ab13e46b_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_groups
    ADD CONSTRAINT bookwyrm_user_groups_group_id_ab13e46b_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_user_groups bookwyrm_user_groups_user_id_595ce39d_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_groups
    ADD CONSTRAINT bookwyrm_user_groups_user_id_595ce39d_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_user bookwyrm_user_key_pair_id_764b8250_fk_bookwyrm_keypair_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_key_pair_id_764b8250_fk_bookwyrm_keypair_id FOREIGN KEY (key_pair_id) REFERENCES public.bookwyrm_keypair(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_user_saved_lists bookwyrm_user_saved_lists_list_id_ccfe32c8_fk_bookwyrm_list_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_saved_lists
    ADD CONSTRAINT bookwyrm_user_saved_lists_list_id_ccfe32c8_fk_bookwyrm_list_id FOREIGN KEY (list_id) REFERENCES public.bookwyrm_list(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_user_saved_lists bookwyrm_user_saved_lists_user_id_e0066a9e_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_saved_lists
    ADD CONSTRAINT bookwyrm_user_saved_lists_user_id_e0066a9e_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_user bookwyrm_user_theme_id_bbaa5748_fk_bookwyrm_theme_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user
    ADD CONSTRAINT bookwyrm_user_theme_id_bbaa5748_fk_bookwyrm_theme_id FOREIGN KEY (theme_id) REFERENCES public.bookwyrm_theme(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_user_user_permissions bookwyrm_user_user_p_permission_id_3f309e47_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_user_permissions
    ADD CONSTRAINT bookwyrm_user_user_p_permission_id_3f309e47_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_user_user_permissions bookwyrm_user_user_p_user_id_a14bcdd0_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_user_user_permissions
    ADD CONSTRAINT bookwyrm_user_user_p_user_id_a14bcdd0_fk_bookwyrm_ FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_userblocks bookwyrm_userblocks_user_object_id_ff33ba18_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userblocks
    ADD CONSTRAINT bookwyrm_userblocks_user_object_id_ff33ba18_fk_bookwyrm_user_id FOREIGN KEY (user_object_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_userblocks bookwyrm_userblocks_user_subject_id_52f9bc38_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userblocks
    ADD CONSTRAINT bookwyrm_userblocks_user_subject_id_52f9bc38_fk_bookwyrm_ FOREIGN KEY (user_subject_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_userfollowrequest bookwyrm_userfollowr_user_object_id_7260db31_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userfollowrequest
    ADD CONSTRAINT bookwyrm_userfollowr_user_object_id_7260db31_fk_bookwyrm_ FOREIGN KEY (user_object_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_userfollowrequest bookwyrm_userfollowr_user_subject_id_6a03a52e_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userfollowrequest
    ADD CONSTRAINT bookwyrm_userfollowr_user_subject_id_6a03a52e_fk_bookwyrm_ FOREIGN KEY (user_subject_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_userfollows bookwyrm_userfollows_user_object_id_01314278_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userfollows
    ADD CONSTRAINT bookwyrm_userfollows_user_object_id_01314278_fk_bookwyrm_ FOREIGN KEY (user_object_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_userfollows bookwyrm_userfollows_user_subject_id_8f86563d_fk_bookwyrm_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_userfollows
    ADD CONSTRAINT bookwyrm_userfollows_user_subject_id_8f86563d_fk_bookwyrm_ FOREIGN KEY (user_subject_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookwyrm_work bookwyrm_work_book_ptr_id_f35dcfe1_fk_bookwyrm_book_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookwyrm_work
    ADD CONSTRAINT bookwyrm_work_book_ptr_id_f35dcfe1_fk_bookwyrm_book_id FOREIGN KEY (book_ptr_id) REFERENCES public.bookwyrm_book(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_bookwyrm_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_bookwyrm_user_id FOREIGN KEY (user_id) REFERENCES public.bookwyrm_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_clocked_id_47a69f82_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_clocked_id_47a69f82_fk_django_ce FOREIGN KEY (clocked_id) REFERENCES public.django_celery_beat_clockedschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_crontab_id_d3cba168_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_crontab_id_d3cba168_fk_django_ce FOREIGN KEY (crontab_id) REFERENCES public.django_celery_beat_crontabschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_interval_id_a8ca27da_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_interval_id_a8ca27da_fk_django_ce FOREIGN KEY (interval_id) REFERENCES public.django_celery_beat_intervalschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_solar_id_a87ce72c_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_solar_id_a87ce72c_fk_django_ce FOREIGN KEY (solar_id) REFERENCES public.django_celery_beat_solarschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--


