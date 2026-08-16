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

--
-- Name: r; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA r;


--
-- Name: utils; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA utils;


--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: actor_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.actor_type_enum AS ENUM (
    'site',
    'community',
    'person'
);


--
-- Name: community_visibility; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.community_visibility AS ENUM (
    'Public',
    'LocalOnly'
);


--
-- Name: listing_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.listing_type_enum AS ENUM (
    'All',
    'Local',
    'Subscribed',
    'ModeratorView'
);


--
-- Name: post_listing_mode_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.post_listing_mode_enum AS ENUM (
    'List',
    'Card',
    'SmallCard'
);


--
-- Name: registration_mode_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.registration_mode_enum AS ENUM (
    'Closed',
    'RequireApplication',
    'Open'
);


--
-- Name: sort_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sort_type_enum AS ENUM (
    'Active',
    'Hot',
    'New',
    'Old',
    'TopDay',
    'TopWeek',
    'TopMonth',
    'TopYear',
    'TopAll',
    'MostComments',
    'NewComments',
    'TopHour',
    'TopSixHour',
    'TopTwelveHour',
    'TopThreeMonths',
    'TopSixMonths',
    'TopNineMonths',
    'Controversial',
    'Scaled'
);


--
-- Name: diesel_manage_updated_at(regclass); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diesel_manage_updated_at(_tbl regclass) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE format('CREATE TRIGGER set_updated_at BEFORE UPDATE ON %s
                    FOR EACH ROW EXECUTE PROCEDURE diesel_set_updated_at()', _tbl);
END;
$$;


--
-- Name: diesel_set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diesel_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (NEW IS DISTINCT FROM OLD AND NEW.updated_at IS NOT DISTINCT FROM OLD.updated_at) THEN
        NEW.updated_at := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: drop_ccnew_indexes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.drop_ccnew_indexes() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    i RECORD;
BEGIN
    FOR i IN (
        SELECT
            relname
        FROM
            pg_class
        WHERE
            relname LIKE '%ccnew%')
        LOOP
            EXECUTE 'DROP INDEX ' || i.relname;
        END LOOP;
    RETURN 1;
END;
$$;


--
-- Name: generate_unique_changeme(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_unique_changeme() RETURNS text
    LANGUAGE sql
    AS $$
    SELECT
        'http://changeme.invalid/seq/' || nextval('changeme_seq')::text;
$$;


--
-- Name: reverse_timestamp_sort(timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reverse_timestamp_sort(t timestamp with time zone) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE
    AS $$
BEGIN
    RETURN (-1000000 * EXTRACT(EPOCH FROM t))::bigint;
END;
$$;


--
-- Name: comment_aggregates_from_comment(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.comment_aggregates_from_comment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO comment_aggregates (comment_id, published)
    SELECT
        id,
        published
    FROM
        new_comment;
    RETURN NULL;
END;
$$;


--
-- Name: comment_change_values(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.comment_change_values() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    id text = NEW.id::text;
BEGIN
    -- Make `path` end with `id` if it doesn't already
    IF NOT (NEW.path ~ ('*.' || id)::lquery) THEN
        NEW.path = NEW.path || id;
    END IF;
    -- Set local ap_id
    IF NEW.local THEN
        NEW.ap_id = coalesce(NEW.ap_id, r.local_url ('/comment/' || id));
    END IF;
    RETURN NEW;
END
$$;


--
-- Name: comment_delete_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.comment_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        comment_count = a.comment_count + diff.comment_count
    FROM (
        SELECT
            (comment).creator_id, coalesce(sum(count_diff), 0) AS comment_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (comment)
        GROUP BY (comment).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.comment_count != 0;

UPDATE
    comment_aggregates AS a
SET
    child_count = a.child_count + diff.child_count
FROM (
    SELECT
        parent_id,
        coalesce(sum(count_diff), 0) AS child_count
    FROM (
        -- For each inserted or deleted comment, this outputs 1 row for each parent comment.
        -- For example, this:
        --
        --  count_diff | (comment).path
        -- ------------+----------------
        --  1          | 0.5.6.7
        --  1          | 0.5.6.7.8
        --
        -- becomes this:
        --
        --  count_diff | parent_id
        -- ------------+-----------
        --  1          | 5
        --  1          | 6
        --  1          | 5
        --  1          | 6
        --  1          | 7
        SELECT
            count_diff,
            parent_id
        FROM
             (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows,
            LATERAL r.parent_comment_ids ((comment).path) AS parent_id) AS expanded_old_and_new_rows
    GROUP BY
        parent_id) AS diff
WHERE
    a.comment_id = diff.parent_id
    AND diff.child_count != 0;

WITH post_diff AS (
    UPDATE
        post_aggregates AS a
    SET
        comments = a.comments + diff.comments,
        newest_comment_time = GREATEST (a.newest_comment_time, diff.newest_comment_time),
        newest_comment_time_necro = GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)
    FROM (
        SELECT
            post.id AS post_id,
            coalesce(sum(count_diff), 0) AS comments,
            -- Old rows are excluded using `count_diff = 1`
            max((comment).published) FILTER (WHERE count_diff = 1) AS newest_comment_time,
            max((comment).published) FILTER (WHERE count_diff = 1
                -- Ignore comments from the post's creator
                AND post.creator_id != (comment).creator_id
            -- Ignore comments on old posts
            AND post.published > ((comment).published - '2 days'::interval)) AS newest_comment_time_necro,
        r.is_counted (post.*) AS include_in_community_aggregates
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
        LEFT JOIN post ON post.id = (comment).post_id
    WHERE
        r.is_counted (comment)
    GROUP BY
        post.id) AS diff
    WHERE
        a.post_id = diff.post_id
        AND (diff.comments,
            GREATEST (a.newest_comment_time, diff.newest_comment_time),
            GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)) != (0,
            a.newest_comment_time,
            a.newest_comment_time_necro)
    RETURNING
        a.community_id,
        diff.comments,
        diff.include_in_community_aggregates)
UPDATE
    community_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        community_id,
        sum(comments) AS comments
    FROM
        post_diff
    WHERE
        post_diff.include_in_community_aggregates
    GROUP BY
        community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.comments != 0;

UPDATE
    site_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS comments
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (comment)
        AND (comment).local) AS diff
WHERE
    diff.comments != 0;

RETURN NULL;

END;

$$;


--
-- Name: comment_insert_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.comment_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        comment_count = a.comment_count + diff.comment_count
    FROM (
        SELECT
            (comment).creator_id, coalesce(sum(count_diff), 0) AS comment_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (comment)
        GROUP BY (comment).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.comment_count != 0;

UPDATE
    comment_aggregates AS a
SET
    child_count = a.child_count + diff.child_count
FROM (
    SELECT
        parent_id,
        coalesce(sum(count_diff), 0) AS child_count
    FROM (
        -- For each inserted or deleted comment, this outputs 1 row for each parent comment.
        -- For example, this:
        --
        --  count_diff | (comment).path
        -- ------------+----------------
        --  1          | 0.5.6.7
        --  1          | 0.5.6.7.8
        --
        -- becomes this:
        --
        --  count_diff | parent_id
        -- ------------+-----------
        --  1          | 5
        --  1          | 6
        --  1          | 5
        --  1          | 6
        --  1          | 7
        SELECT
            count_diff,
            parent_id
        FROM
             (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows,
            LATERAL r.parent_comment_ids ((comment).path) AS parent_id) AS expanded_old_and_new_rows
    GROUP BY
        parent_id) AS diff
WHERE
    a.comment_id = diff.parent_id
    AND diff.child_count != 0;

WITH post_diff AS (
    UPDATE
        post_aggregates AS a
    SET
        comments = a.comments + diff.comments,
        newest_comment_time = GREATEST (a.newest_comment_time, diff.newest_comment_time),
        newest_comment_time_necro = GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)
    FROM (
        SELECT
            post.id AS post_id,
            coalesce(sum(count_diff), 0) AS comments,
            -- Old rows are excluded using `count_diff = 1`
            max((comment).published) FILTER (WHERE count_diff = 1) AS newest_comment_time,
            max((comment).published) FILTER (WHERE count_diff = 1
                -- Ignore comments from the post's creator
                AND post.creator_id != (comment).creator_id
            -- Ignore comments on old posts
            AND post.published > ((comment).published - '2 days'::interval)) AS newest_comment_time_necro,
        r.is_counted (post.*) AS include_in_community_aggregates
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        LEFT JOIN post ON post.id = (comment).post_id
    WHERE
        r.is_counted (comment)
    GROUP BY
        post.id) AS diff
    WHERE
        a.post_id = diff.post_id
        AND (diff.comments,
            GREATEST (a.newest_comment_time, diff.newest_comment_time),
            GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)) != (0,
            a.newest_comment_time,
            a.newest_comment_time_necro)
    RETURNING
        a.community_id,
        diff.comments,
        diff.include_in_community_aggregates)
UPDATE
    community_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        community_id,
        sum(comments) AS comments
    FROM
        post_diff
    WHERE
        post_diff.include_in_community_aggregates
    GROUP BY
        community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.comments != 0;

UPDATE
    site_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS comments
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (comment)
        AND (comment).local) AS diff
WHERE
    diff.comments != 0;

RETURN NULL;

END;

$$;


--
-- Name: comment_like_delete_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.comment_like_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH comment_diff AS ( UPDATE
                        comment_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (comment_like).comment_id, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment_like AS comment_like
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment_like AS comment_like
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows GROUP BY (comment_like).comment_id) AS diff
            WHERE
                a.comment_id = diff.comment_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_comment_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                comment_score = a.comment_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM comment_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


--
-- Name: comment_like_insert_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.comment_like_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH comment_diff AS ( UPDATE
                        comment_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (comment_like).comment_id, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment_like AS comment_like
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment_like AS comment_like
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows GROUP BY (comment_like).comment_id) AS diff
            WHERE
                a.comment_id = diff.comment_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_comment_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                comment_score = a.comment_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM comment_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


--
-- Name: comment_like_update_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.comment_like_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH comment_diff AS ( UPDATE
                        comment_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (comment_like).comment_id, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment_like AS comment_like
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment_like AS comment_like
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows GROUP BY (comment_like).comment_id) AS diff
            WHERE
                a.comment_id = diff.comment_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_comment_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                comment_score = a.comment_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM comment_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


--
-- Name: comment_update_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.comment_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        comment_count = a.comment_count + diff.comment_count
    FROM (
        SELECT
            (comment).creator_id, coalesce(sum(count_diff), 0) AS comment_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (comment)
        GROUP BY (comment).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.comment_count != 0;

UPDATE
    comment_aggregates AS a
SET
    child_count = a.child_count + diff.child_count
FROM (
    SELECT
        parent_id,
        coalesce(sum(count_diff), 0) AS child_count
    FROM (
        -- For each inserted or deleted comment, this outputs 1 row for each parent comment.
        -- For example, this:
        --
        --  count_diff | (comment).path
        -- ------------+----------------
        --  1          | 0.5.6.7
        --  1          | 0.5.6.7.8
        --
        -- becomes this:
        --
        --  count_diff | parent_id
        -- ------------+-----------
        --  1          | 5
        --  1          | 6
        --  1          | 5
        --  1          | 6
        --  1          | 7
        SELECT
            count_diff,
            parent_id
        FROM
             (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows,
            LATERAL r.parent_comment_ids ((comment).path) AS parent_id) AS expanded_old_and_new_rows
    GROUP BY
        parent_id) AS diff
WHERE
    a.comment_id = diff.parent_id
    AND diff.child_count != 0;

WITH post_diff AS (
    UPDATE
        post_aggregates AS a
    SET
        comments = a.comments + diff.comments,
        newest_comment_time = GREATEST (a.newest_comment_time, diff.newest_comment_time),
        newest_comment_time_necro = GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)
    FROM (
        SELECT
            post.id AS post_id,
            coalesce(sum(count_diff), 0) AS comments,
            -- Old rows are excluded using `count_diff = 1`
            max((comment).published) FILTER (WHERE count_diff = 1) AS newest_comment_time,
            max((comment).published) FILTER (WHERE count_diff = 1
                -- Ignore comments from the post's creator
                AND post.creator_id != (comment).creator_id
            -- Ignore comments on old posts
            AND post.published > ((comment).published - '2 days'::interval)) AS newest_comment_time_necro,
        r.is_counted (post.*) AS include_in_community_aggregates
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        LEFT JOIN post ON post.id = (comment).post_id
    WHERE
        r.is_counted (comment)
    GROUP BY
        post.id) AS diff
    WHERE
        a.post_id = diff.post_id
        AND (diff.comments,
            GREATEST (a.newest_comment_time, diff.newest_comment_time),
            GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)) != (0,
            a.newest_comment_time,
            a.newest_comment_time_necro)
    RETURNING
        a.community_id,
        diff.comments,
        diff.include_in_community_aggregates)
UPDATE
    community_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        community_id,
        sum(comments) AS comments
    FROM
        post_diff
    WHERE
        post_diff.include_in_community_aggregates
    GROUP BY
        community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.comments != 0;

UPDATE
    site_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS comments
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (comment)
        AND (comment).local) AS diff
WHERE
    diff.comments != 0;

RETURN NULL;

END;

$$;


--
-- Name: community_aggregates_activity(text); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.community_aggregates_activity(i text) RETURNS TABLE(count_ bigint, community_id_ integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query
    SELECT
        count(*),
        community_id
    FROM (
        SELECT
            c.creator_id,
            p.community_id
        FROM
            comment c
            INNER JOIN post p ON c.post_id = p.id
            INNER JOIN person pe ON c.creator_id = pe.id
        WHERE
            c.published > ('now'::timestamp - i::interval)
            AND pe.bot_account = FALSE
        UNION
        SELECT
            p.creator_id,
            p.community_id
        FROM
            post p
            INNER JOIN person pe ON p.creator_id = pe.id
        WHERE
            p.published > ('now'::timestamp - i::interval)
            AND pe.bot_account = FALSE
        UNION
        SELECT
            pl.person_id,
            p.community_id
        FROM
            post_like pl
            INNER JOIN post p ON pl.post_id = p.id
            INNER JOIN person pe ON pl.person_id = pe.id
        WHERE
            pl.published > ('now'::timestamp - i::interval)
            AND pe.bot_account = FALSE
        UNION
        SELECT
            cl.person_id,
            p.community_id
        FROM
            comment_like cl
            INNER JOIN comment c ON cl.comment_id = c.id
            INNER JOIN post p ON c.post_id = p.id
            INNER JOIN person pe ON cl.person_id = pe.id
        WHERE
            cl.published > ('now'::timestamp - i::interval)
            AND pe.bot_account = FALSE) a
GROUP BY
    community_id;
END;
$$;


--
-- Name: community_aggregates_from_community(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.community_aggregates_from_community() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO community_aggregates (community_id, published)
    SELECT
        id,
        published
    FROM
        new_community;
    RETURN NULL;
END;
$$;


--
-- Name: community_delete_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.community_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        communities = a.communities + diff.communities
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS communities
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community AS community
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community AS community
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (community)
            AND (community).local) AS diff
WHERE
    diff.communities != 0;

RETURN NULL;

END;

$$;


--
-- Name: community_follower_delete_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.community_follower_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        community_aggregates AS a
    SET
        subscribers = a.subscribers + diff.subscribers, subscribers_local = a.subscribers_local + diff.subscribers_local
    FROM (
        SELECT
            (community_follower).community_id, coalesce(sum(count_diff) FILTER (WHERE community.local), 0) AS subscribers, coalesce(sum(count_diff) FILTER (WHERE person.local), 0) AS subscribers_local
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community_follower AS community_follower
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community_follower AS community_follower
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
    LEFT JOIN community ON community.id = (community_follower).community_id
    LEFT JOIN person ON person.id = (community_follower).person_id GROUP BY (community_follower).community_id) AS diff
WHERE
    a.community_id = diff.community_id
        AND (diff.subscribers, diff.subscribers_local) != (0, 0);

RETURN NULL;

END;

$$;


--
-- Name: community_follower_insert_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.community_follower_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        community_aggregates AS a
    SET
        subscribers = a.subscribers + diff.subscribers, subscribers_local = a.subscribers_local + diff.subscribers_local
    FROM (
        SELECT
            (community_follower).community_id, coalesce(sum(count_diff) FILTER (WHERE community.local), 0) AS subscribers, coalesce(sum(count_diff) FILTER (WHERE person.local), 0) AS subscribers_local
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community_follower AS community_follower
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community_follower AS community_follower
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    LEFT JOIN community ON community.id = (community_follower).community_id
    LEFT JOIN person ON person.id = (community_follower).person_id GROUP BY (community_follower).community_id) AS diff
WHERE
    a.community_id = diff.community_id
        AND (diff.subscribers, diff.subscribers_local) != (0, 0);

RETURN NULL;

END;

$$;


--
-- Name: community_follower_update_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.community_follower_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        community_aggregates AS a
    SET
        subscribers = a.subscribers + diff.subscribers, subscribers_local = a.subscribers_local + diff.subscribers_local
    FROM (
        SELECT
            (community_follower).community_id, coalesce(sum(count_diff) FILTER (WHERE community.local), 0) AS subscribers, coalesce(sum(count_diff) FILTER (WHERE person.local), 0) AS subscribers_local
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community_follower AS community_follower
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community_follower AS community_follower
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    LEFT JOIN community ON community.id = (community_follower).community_id
    LEFT JOIN person ON person.id = (community_follower).person_id GROUP BY (community_follower).community_id) AS diff
WHERE
    a.community_id = diff.community_id
        AND (diff.subscribers, diff.subscribers_local) != (0, 0);

RETURN NULL;

END;

$$;


--
-- Name: community_insert_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.community_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        communities = a.communities + diff.communities
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS communities
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community AS community
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community AS community
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (community)
            AND (community).local) AS diff
WHERE
    diff.communities != 0;

RETURN NULL;

END;

$$;


--
-- Name: community_update_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.community_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        communities = a.communities + diff.communities
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS communities
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community AS community
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community AS community
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (community)
            AND (community).local) AS diff
WHERE
    diff.communities != 0;

RETURN NULL;

END;

$$;


--
-- Name: controversy_rank(numeric, numeric); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.controversy_rank(upvotes numeric, downvotes numeric) RETURNS double precision
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    RETURN CASE WHEN ((downvotes <= (0)::numeric) OR (upvotes <= (0)::numeric)) THEN (0)::double precision ELSE (((upvotes + downvotes))::double precision ^ CASE WHEN (upvotes > downvotes) THEN ((downvotes)::double precision / (upvotes)::double precision) ELSE ((upvotes)::double precision / (downvotes)::double precision) END) END;


--
-- Name: create_triggers(text, text); Type: PROCEDURE; Schema: r; Owner: -
--

CREATE PROCEDURE r.create_triggers(IN table_name text, IN function_body text)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    defs text := $$
    -- Delete
    CREATE FUNCTION r.thing_delete_statement ()
        RETURNS TRIGGER
        LANGUAGE plpgsql
        AS function_body_delete;
    CREATE TRIGGER delete_statement
        AFTER DELETE ON thing REFERENCING OLD TABLE AS select_old_rows
        FOR EACH STATEMENT
        EXECUTE FUNCTION r.thing_delete_statement ( );
    -- Insert
    CREATE FUNCTION r.thing_insert_statement ( )
        RETURNS TRIGGER
        LANGUAGE plpgsql
        AS function_body_insert;
    CREATE TRIGGER insert_statement
        AFTER INSERT ON thing REFERENCING NEW TABLE AS select_new_rows
        FOR EACH STATEMENT
        EXECUTE FUNCTION r.thing_insert_statement ( );
    -- Update
    CREATE FUNCTION r.thing_update_statement ( )
        RETURNS TRIGGER
        LANGUAGE plpgsql
        AS function_body_update;
    CREATE TRIGGER update_statement
        AFTER UPDATE ON thing REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows
        FOR EACH STATEMENT
        EXECUTE FUNCTION r.thing_update_statement ( );
    $$;
    select_old_and_new_rows text := $$ (
        SELECT
            -1 AS count_diff,
            old_table::thing AS thing
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::thing AS thing
        FROM
            select_new_rows AS new_table) $$;
    empty_select_new_rows text := $$ (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE) $$;
    empty_select_old_rows text := $$ (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE) $$;
    BEGIN
        function_body := replace(function_body, 'select_old_and_new_rows', select_old_and_new_rows);
        -- `select_old_rows` and `select_new_rows` are made available as empty tables if they don't already exist
        defs := replace(defs, 'function_body_delete', quote_literal(replace(function_body, 'select_new_rows', empty_select_new_rows)));
        defs := replace(defs, 'function_body_insert', quote_literal(replace(function_body, 'select_old_rows', empty_select_old_rows)));
        defs := replace(defs, 'function_body_update', quote_literal(function_body));
        defs := replace(defs, 'thing', table_name);
        EXECUTE defs;
END;
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    post_id integer NOT NULL,
    content text NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    deleted boolean DEFAULT false NOT NULL,
    ap_id character varying(255) NOT NULL,
    local boolean DEFAULT true NOT NULL,
    path public.ltree DEFAULT '0'::public.ltree NOT NULL,
    distinguished boolean DEFAULT false NOT NULL,
    language_id integer DEFAULT 0 NOT NULL
);


--
-- Name: comment_aggregates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_aggregates (
    comment_id integer NOT NULL,
    score bigint DEFAULT 0 NOT NULL,
    upvotes bigint DEFAULT 0 NOT NULL,
    downvotes bigint DEFAULT 0 NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    child_count integer DEFAULT 0 NOT NULL,
    hot_rank double precision DEFAULT 0.0001 NOT NULL,
    controversy_rank double precision DEFAULT 0 NOT NULL
);


--
-- Name: creator_id_from_comment_aggregates(public.comment_aggregates); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.creator_id_from_comment_aggregates(agg public.comment_aggregates) RETURNS integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    RETURN (SELECT comment.creator_id FROM public.comment WHERE (comment.id = (creator_id_from_comment_aggregates.agg).comment_id) LIMIT 1);


--
-- Name: post_aggregates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_aggregates (
    post_id integer NOT NULL,
    comments bigint DEFAULT 0 NOT NULL,
    score bigint DEFAULT 0 NOT NULL,
    upvotes bigint DEFAULT 0 NOT NULL,
    downvotes bigint DEFAULT 0 NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    newest_comment_time_necro timestamp with time zone DEFAULT now() NOT NULL,
    newest_comment_time timestamp with time zone DEFAULT now() NOT NULL,
    featured_community boolean DEFAULT false NOT NULL,
    featured_local boolean DEFAULT false NOT NULL,
    hot_rank double precision DEFAULT 0.0001 NOT NULL,
    hot_rank_active double precision DEFAULT 0.0001 NOT NULL,
    community_id integer NOT NULL,
    creator_id integer NOT NULL,
    controversy_rank double precision DEFAULT 0 NOT NULL,
    instance_id integer NOT NULL,
    scaled_rank double precision DEFAULT 0.0001 NOT NULL
);


--
-- Name: creator_id_from_post_aggregates(public.post_aggregates); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.creator_id_from_post_aggregates(agg public.post_aggregates) RETURNS integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    RETURN (agg).creator_id;


--
-- Name: delete_comments_before_post(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.delete_comments_before_post() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM comment AS c
    WHERE c.post_id = OLD.id;
    RETURN OLD;
END;
$$;


--
-- Name: delete_follow_before_person(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.delete_follow_before_person() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM community_follower AS c
    WHERE c.person_id = OLD.id;
    RETURN OLD;
END;
$$;


--
-- Name: hot_rank(numeric, timestamp with time zone); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.hot_rank(score numeric, published timestamp with time zone) RETURNS double precision
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    RETURN CASE WHEN (((now() - published) > '00:00:00'::interval) AND ((now() - published) < '7 days'::interval)) THEN (log(GREATEST((2)::numeric, (score + (2)::numeric))) / power(((EXTRACT(epoch FROM (now() - published)) / (3600)::numeric) + (2)::numeric), 1.8)) ELSE 0.0 END;


--
-- Name: is_counted(record); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.is_counted(item record) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE
    AS $$
BEGIN
    RETURN COALESCE(NOT (item.deleted
            OR item.removed), FALSE);
END;
$$;


--
-- Name: local_url(text); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.local_url(url_path text) RETURNS text
    LANGUAGE sql STABLE PARALLEL SAFE
    RETURN (current_setting('lemmy.protocol_and_hostname'::text) || url_path);


--
-- Name: local_user_delete_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.local_user_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        users = a.users + diff.users
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS users
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::local_user AS local_user
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::local_user AS local_user
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
        WHERE (local_user).accepted_application) AS diff
WHERE
    diff.users != 0;

RETURN NULL;

END;

$$;


--
-- Name: local_user_insert_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.local_user_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        users = a.users + diff.users
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS users
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::local_user AS local_user
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::local_user AS local_user
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE (local_user).accepted_application) AS diff
WHERE
    diff.users != 0;

RETURN NULL;

END;

$$;


--
-- Name: local_user_update_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.local_user_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        users = a.users + diff.users
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS users
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::local_user AS local_user
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::local_user AS local_user
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE (local_user).accepted_application) AS diff
WHERE
    diff.users != 0;

RETURN NULL;

END;

$$;


--
-- Name: parent_comment_ids(public.ltree); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.parent_comment_ids(path public.ltree) RETURNS SETOF integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    BEGIN ATOMIC
 SELECT (comment_id.comment_id)::integer AS comment_id
    FROM string_to_table(public.ltree2text(parent_comment_ids.path), '.'::text) comment_id(comment_id)
  OFFSET 1
  LIMIT (public.nlevel(parent_comment_ids.path) - 2);
END;


--
-- Name: person_aggregates_from_person(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.person_aggregates_from_person() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO person_aggregates (person_id)
    SELECT
        id
    FROM
        new_person;
    RETURN NULL;
END;
$$;


--
-- Name: post_aggregates_from_post(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.post_aggregates_from_post() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO post_aggregates (post_id, published, newest_comment_time, newest_comment_time_necro, community_id, creator_id, instance_id, featured_community, featured_local)
    SELECT
        new_post.id,
        new_post.published,
        new_post.published,
        new_post.published,
        new_post.community_id,
        new_post.creator_id,
        community.instance_id,
        new_post.featured_community,
        new_post.featured_local
    FROM
        new_post
        INNER JOIN community ON community.id = new_post.community_id;
    RETURN NULL;
END;
$$;


--
-- Name: post_aggregates_from_post_update(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.post_aggregates_from_post_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        post_aggregates
    SET
        featured_community = new_post.featured_community,
        featured_local = new_post.featured_local
    FROM
        new_post
        INNER JOIN old_post ON old_post.id = new_post.id
            AND (old_post.featured_community,
                old_post.featured_local) != (new_post.featured_community,
                new_post.featured_local)
    WHERE
        post_aggregates.post_id = new_post.id;
    RETURN NULL;
END;
$$;


--
-- Name: post_change_values(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.post_change_values() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Set local ap_id
    IF NEW.local THEN
        NEW.ap_id = coalesce(NEW.ap_id, r.local_url ('/post/' || NEW.id::text));
    END IF;
    RETURN NEW;
END
$$;


--
-- Name: post_delete_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.post_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        post_count = a.post_count + diff.post_count
    FROM (
        SELECT
            (post).creator_id, coalesce(sum(count_diff), 0) AS post_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (post)
        GROUP BY (post).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.post_count != 0;

UPDATE
    community_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        (post).community_id,
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
    GROUP BY
        (post).community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.posts != 0;

UPDATE
    site_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
        AND (post).local) AS diff
WHERE
    diff.posts != 0;

RETURN NULL;

END;

$$;


--
-- Name: post_insert_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.post_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        post_count = a.post_count + diff.post_count
    FROM (
        SELECT
            (post).creator_id, coalesce(sum(count_diff), 0) AS post_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (post)
        GROUP BY (post).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.post_count != 0;

UPDATE
    community_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        (post).community_id,
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
    GROUP BY
        (post).community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.posts != 0;

UPDATE
    site_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
        AND (post).local) AS diff
WHERE
    diff.posts != 0;

RETURN NULL;

END;

$$;


--
-- Name: post_like_delete_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.post_like_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH post_diff AS ( UPDATE
                        post_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (post_like).post_id, coalesce(sum(count_diff) FILTER (WHERE (post_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (post_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post_like AS post_like
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post_like AS post_like
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows GROUP BY (post_like).post_id) AS diff
            WHERE
                a.post_id = diff.post_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_post_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                post_score = a.post_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM post_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


--
-- Name: post_like_insert_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.post_like_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH post_diff AS ( UPDATE
                        post_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (post_like).post_id, coalesce(sum(count_diff) FILTER (WHERE (post_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (post_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post_like AS post_like
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post_like AS post_like
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows GROUP BY (post_like).post_id) AS diff
            WHERE
                a.post_id = diff.post_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_post_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                post_score = a.post_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM post_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


--
-- Name: post_like_update_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.post_like_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH post_diff AS ( UPDATE
                        post_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (post_like).post_id, coalesce(sum(count_diff) FILTER (WHERE (post_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (post_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post_like AS post_like
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post_like AS post_like
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows GROUP BY (post_like).post_id) AS diff
            WHERE
                a.post_id = diff.post_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_post_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                post_score = a.post_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM post_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


--
-- Name: post_or_comment(text); Type: PROCEDURE; Schema: r; Owner: -
--

CREATE PROCEDURE r.post_or_comment(IN table_name text)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    EXECUTE replace($b$
        -- When a thing gets a vote, update its aggregates and its creator's aggregates
        CALL r.create_triggers ('thing_like', $$
            BEGIN
                WITH thing_diff AS ( UPDATE
                        thing_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (thing_like).thing_id, coalesce(sum(count_diff) FILTER (WHERE (thing_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (thing_like).score != 1), 0) AS downvotes FROM select_old_and_new_rows AS old_and_new_rows GROUP BY (thing_like).thing_id) AS diff
            WHERE
                a.thing_id = diff.thing_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_thing_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                thing_score = a.thing_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM thing_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$);
    $b$,
    'thing',
    table_name);
END;
$_$;


--
-- Name: post_update_statement(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.post_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        post_count = a.post_count + diff.post_count
    FROM (
        SELECT
            (post).creator_id, coalesce(sum(count_diff), 0) AS post_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (post)
        GROUP BY (post).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.post_count != 0;

UPDATE
    community_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        (post).community_id,
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
    GROUP BY
        (post).community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.posts != 0;

UPDATE
    site_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
        AND (post).local) AS diff
WHERE
    diff.posts != 0;

RETURN NULL;

END;

$$;


--
-- Name: private_message_change_values(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.private_message_change_values() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Set local ap_id
    IF NEW.local THEN
        NEW.ap_id = coalesce(NEW.ap_id, r.local_url ('/private_message/' || NEW.id::text));
    END IF;
    RETURN NEW;
END
$$;


--
-- Name: scaled_rank(numeric, timestamp with time zone, numeric); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.scaled_rank(score numeric, published timestamp with time zone, users_active_month numeric) RETURNS double precision
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    RETURN (r.hot_rank(score, published) / (log(((2)::numeric + users_active_month)))::double precision);


--
-- Name: site_aggregates_activity(text); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.site_aggregates_activity(i text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    count_ integer;
BEGIN
    SELECT
        count(*) INTO count_
    FROM (
        SELECT
            c.creator_id
        FROM
            comment c
            INNER JOIN person pe ON c.creator_id = pe.id
        WHERE
            c.published > ('now'::timestamp - i::interval)
            AND pe.local = TRUE
            AND pe.bot_account = FALSE
        UNION
        SELECT
            p.creator_id
        FROM
            post p
            INNER JOIN person pe ON p.creator_id = pe.id
        WHERE
            p.published > ('now'::timestamp - i::interval)
            AND pe.local = TRUE
            AND pe.bot_account = FALSE
        UNION
        SELECT
            pl.person_id
        FROM
            post_like pl
            INNER JOIN person pe ON pl.person_id = pe.id
        WHERE
            pl.published > ('now'::timestamp - i::interval)
            AND pe.local = TRUE
            AND pe.bot_account = FALSE
        UNION
        SELECT
            cl.person_id
        FROM
            comment_like cl
            INNER JOIN person pe ON cl.person_id = pe.id
        WHERE
            cl.published > ('now'::timestamp - i::interval)
            AND pe.local = TRUE
            AND pe.bot_account = FALSE) a;
    RETURN count_;
END;
$$;


--
-- Name: site_aggregates_from_site(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.site_aggregates_from_site() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- only 1 row can be in site_aggregates because of the index idx_site_aggregates_1_row_only.
    -- we only ever want to have a single value in site_aggregate because the site_aggregate triggers update all rows in that table.
    -- a cleaner check would be to insert it for the local_site but that would break assumptions at least in the tests
    INSERT INTO site_aggregates (site_id)
        VALUES (NEW.id)
    ON CONFLICT ((TRUE))
        DO NOTHING;
    RETURN NULL;
END;
$$;


--
-- Name: update_comment_count_from_post(); Type: FUNCTION; Schema: r; Owner: -
--

CREATE FUNCTION r.update_comment_count_from_post() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        community_aggregates AS a
    SET
        comments = a.comments + diff.comments
    FROM (
        SELECT
            old_post.community_id,
            sum((
                CASE WHEN r.is_counted (new_post.*) THEN
                    1
                ELSE
                    -1
                END) * post_aggregates.comments) AS comments
        FROM
            new_post
            INNER JOIN old_post ON new_post.id = old_post.id
                AND (r.is_counted (new_post.*) != r.is_counted (old_post.*))
                INNER JOIN post_aggregates ON post_aggregates.post_id = new_post.id
            GROUP BY
                old_post.community_id) AS diff
WHERE
    a.community_id = diff.community_id
        AND diff.comments != 0;
    RETURN NULL;
END;
$$;


--
-- Name: restore_views(character varying, character varying); Type: FUNCTION; Schema: utils; Owner: -
--

CREATE FUNCTION utils.restore_views(p_view_schema character varying, p_view_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_curr record;
BEGIN
    FOR v_curr IN (
        SELECT
            ddl_to_run,
            id
        FROM
            utils.deps_saved_ddl
        WHERE
            view_schema = p_view_schema
            AND view_name = p_view_name
        ORDER BY
            id DESC)
            LOOP
                BEGIN
                    EXECUTE v_curr.ddl_to_run;
                    DELETE FROM utils.deps_saved_ddl
                    WHERE id = v_curr.id;
                EXCEPTION
                    WHEN OTHERS THEN
                        -- keep looping, but please check for errors or remove left overs to handle manually
                END;
    END LOOP;
END;

$$;


--
-- Name: save_and_drop_views(name, name); Type: FUNCTION; Schema: utils; Owner: -
--

CREATE FUNCTION utils.save_and_drop_views(p_view_schema name, p_view_name name) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_curr record;
BEGIN
    FOR v_curr IN (
        SELECT
            obj_schema,
            obj_name,
            obj_type
        FROM ( WITH RECURSIVE recursive_deps (
                obj_schema,
                obj_name,
                obj_type,
                depth
) AS (
                SELECT
                    p_view_schema::name,
                    p_view_name,
                    NULL::varchar,
                    0
                UNION
                SELECT
                    dep_schema::varchar,
                    dep_name::varchar,
                    dep_type::varchar,
                    recursive_deps.depth + 1
                FROM (
                    SELECT
                        ref_nsp.nspname ref_schema,
                        ref_cl.relname ref_name,
                        rwr_cl.relkind dep_type,
                        rwr_nsp.nspname dep_schema,
                        rwr_cl.relname dep_name
                    FROM
                        pg_depend dep
                        JOIN pg_class ref_cl ON dep.refobjid = ref_cl.oid
                        JOIN pg_namespace ref_nsp ON ref_cl.relnamespace = ref_nsp.oid
                        JOIN pg_rewrite rwr ON dep.objid = rwr.oid
                        JOIN pg_class rwr_cl ON rwr.ev_class = rwr_cl.oid
                        JOIN pg_namespace rwr_nsp ON rwr_cl.relnamespace = rwr_nsp.oid
                    WHERE
                        dep.deptype = 'n'
                        AND dep.classid = 'pg_rewrite'::regclass) deps
                    JOIN recursive_deps ON deps.ref_schema = recursive_deps.obj_schema
                        AND deps.ref_name = recursive_deps.obj_name
                WHERE (deps.ref_schema != deps.dep_schema
                    OR deps.ref_name != deps.dep_name))
            SELECT
                obj_schema,
                obj_name,
                obj_type,
                depth
            FROM
                recursive_deps
            WHERE
                depth > 0) t
        GROUP BY
            obj_schema,
            obj_name,
            obj_type
        ORDER BY
            max(depth) DESC)
            LOOP
                IF v_curr.obj_type = 'v' THEN
                    INSERT INTO utils.deps_saved_ddl (view_schema, view_name, ddl_to_run)
                    SELECT
                        p_view_schema,
                        p_view_name,
                        'CREATE VIEW ' || v_curr.obj_schema || '.' || v_curr.obj_name || ' AS ' || view_definition
                    FROM
                        information_schema.views
                    WHERE
                        table_schema = v_curr.obj_schema
                        AND table_name = v_curr.obj_name;
                    EXECUTE 'DROP VIEW' || ' ' || v_curr.obj_schema || '.' || v_curr.obj_name;
                END IF;
            END LOOP;
END;
$$;


--
-- Name: __diesel_schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.__diesel_schema_migrations (
    version character varying(50) NOT NULL,
    run_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: admin_purge_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_purge_comment (
    id integer NOT NULL,
    admin_person_id integer NOT NULL,
    post_id integer NOT NULL,
    reason text,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: admin_purge_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_purge_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_purge_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_purge_comment_id_seq OWNED BY public.admin_purge_comment.id;


--
-- Name: admin_purge_community; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_purge_community (
    id integer NOT NULL,
    admin_person_id integer NOT NULL,
    reason text,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: admin_purge_community_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_purge_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_purge_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_purge_community_id_seq OWNED BY public.admin_purge_community.id;


--
-- Name: admin_purge_person; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_purge_person (
    id integer NOT NULL,
    admin_person_id integer NOT NULL,
    reason text,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: admin_purge_person_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_purge_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_purge_person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_purge_person_id_seq OWNED BY public.admin_purge_person.id;


--
-- Name: admin_purge_post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_purge_post (
    id integer NOT NULL,
    admin_person_id integer NOT NULL,
    community_id integer NOT NULL,
    reason text,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: admin_purge_post_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_purge_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_purge_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_purge_post_id_seq OWNED BY public.admin_purge_post.id;


--
-- Name: captcha_answer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.captcha_answer (
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    answer text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: changeme_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.changeme_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE;


--
-- Name: comment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comment_id_seq OWNED BY public.comment.id;


--
-- Name: comment_like; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_like (
    person_id integer NOT NULL,
    comment_id integer NOT NULL,
    post_id integer NOT NULL,
    score smallint NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: comment_reply; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_reply (
    id integer NOT NULL,
    recipient_id integer NOT NULL,
    comment_id integer NOT NULL,
    read boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: comment_reply_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_reply_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_reply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comment_reply_id_seq OWNED BY public.comment_reply.id;


--
-- Name: comment_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_report (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    comment_id integer NOT NULL,
    original_comment_text text NOT NULL,
    reason text NOT NULL,
    resolved boolean DEFAULT false NOT NULL,
    resolver_id integer,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


--
-- Name: comment_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comment_report_id_seq OWNED BY public.comment_report.id;


--
-- Name: comment_saved; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_saved (
    comment_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: community; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    removed boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    deleted boolean DEFAULT false NOT NULL,
    nsfw boolean DEFAULT false NOT NULL,
    actor_id character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    local boolean DEFAULT true NOT NULL,
    private_key text,
    public_key text NOT NULL,
    last_refreshed_at timestamp with time zone DEFAULT now() NOT NULL,
    icon text,
    banner text,
    followers_url character varying(255) DEFAULT public.generate_unique_changeme(),
    inbox_url character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    shared_inbox_url character varying(255),
    hidden boolean DEFAULT false NOT NULL,
    posting_restricted_to_mods boolean DEFAULT false NOT NULL,
    instance_id integer NOT NULL,
    moderators_url character varying(255),
    featured_url character varying(255),
    visibility public.community_visibility DEFAULT 'Public'::public.community_visibility NOT NULL
);


--
-- Name: community_aggregates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_aggregates (
    community_id integer NOT NULL,
    subscribers bigint DEFAULT 0 NOT NULL,
    posts bigint DEFAULT 0 NOT NULL,
    comments bigint DEFAULT 0 NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    users_active_day bigint DEFAULT 0 NOT NULL,
    users_active_week bigint DEFAULT 0 NOT NULL,
    users_active_month bigint DEFAULT 0 NOT NULL,
    users_active_half_year bigint DEFAULT 0 NOT NULL,
    hot_rank double precision DEFAULT 0.0001 NOT NULL,
    subscribers_local bigint DEFAULT 0 NOT NULL
);


--
-- Name: community_block; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_block (
    person_id integer NOT NULL,
    community_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: community_follower; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_follower (
    community_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    pending boolean DEFAULT false NOT NULL
);


--
-- Name: community_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.community_id_seq OWNED BY public.community.id;


--
-- Name: community_language; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_language (
    community_id integer NOT NULL,
    language_id integer NOT NULL
);


--
-- Name: community_moderator; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_moderator (
    community_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: community_person_ban; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_person_ban (
    community_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    expires timestamp with time zone
);


--
-- Name: custom_emoji; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_emoji (
    id integer NOT NULL,
    local_site_id integer NOT NULL,
    shortcode character varying(128) NOT NULL,
    image_url text NOT NULL,
    alt_text text NOT NULL,
    category text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


--
-- Name: custom_emoji_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_emoji_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_emoji_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_emoji_id_seq OWNED BY public.custom_emoji.id;


--
-- Name: custom_emoji_keyword; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_emoji_keyword (
    custom_emoji_id integer NOT NULL,
    keyword character varying(128) NOT NULL
);


--
-- Name: email_verification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_verification (
    id integer NOT NULL,
    local_user_id integer NOT NULL,
    email text NOT NULL,
    verification_token text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: email_verification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_verification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_verification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_verification_id_seq OWNED BY public.email_verification.id;


--
-- Name: federation_allowlist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.federation_allowlist (
    instance_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


--
-- Name: federation_blocklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.federation_blocklist (
    instance_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


--
-- Name: federation_queue_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.federation_queue_state (
    instance_id integer NOT NULL,
    last_successful_id bigint,
    fail_count integer NOT NULL,
    last_retry timestamp with time zone,
    last_successful_published_time timestamp with time zone
);


--
-- Name: image_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_details (
    link text NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    content_type text NOT NULL
);


--
-- Name: instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instance (
    id integer NOT NULL,
    domain character varying(255) NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    software character varying(255),
    version character varying(255)
);


--
-- Name: instance_block; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instance_block (
    person_id integer NOT NULL,
    instance_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.instance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.instance_id_seq OWNED BY public.instance.id;


--
-- Name: language; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.language (
    id integer NOT NULL,
    code character varying(3) NOT NULL,
    name text NOT NULL
);


--
-- Name: language_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.language_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: language_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.language_id_seq OWNED BY public.language.id;


--
-- Name: local_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_image (
    local_user_id integer,
    pictrs_alias text NOT NULL,
    pictrs_delete_token text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: local_site; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_site (
    id integer NOT NULL,
    site_id integer NOT NULL,
    site_setup boolean DEFAULT false NOT NULL,
    enable_downvotes boolean DEFAULT true NOT NULL,
    enable_nsfw boolean DEFAULT true NOT NULL,
    community_creation_admin_only boolean DEFAULT false NOT NULL,
    require_email_verification boolean DEFAULT false NOT NULL,
    application_question text DEFAULT 'to verify that you are human, please explain why you want to create an account on this site'::text,
    private_instance boolean DEFAULT false NOT NULL,
    default_theme text DEFAULT 'browser'::text NOT NULL,
    default_post_listing_type public.listing_type_enum DEFAULT 'Local'::public.listing_type_enum NOT NULL,
    legal_information text,
    hide_modlog_mod_names boolean DEFAULT true NOT NULL,
    application_email_admins boolean DEFAULT false NOT NULL,
    slur_filter_regex text,
    actor_name_max_length integer DEFAULT 20 NOT NULL,
    federation_enabled boolean DEFAULT true NOT NULL,
    captcha_enabled boolean DEFAULT false NOT NULL,
    captcha_difficulty character varying(255) DEFAULT 'medium'::character varying NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    registration_mode public.registration_mode_enum DEFAULT 'RequireApplication'::public.registration_mode_enum NOT NULL,
    reports_email_admins boolean DEFAULT false NOT NULL,
    federation_signed_fetch boolean DEFAULT false NOT NULL,
    default_post_listing_mode public.post_listing_mode_enum DEFAULT 'List'::public.post_listing_mode_enum NOT NULL,
    default_sort_type public.sort_type_enum DEFAULT 'Active'::public.sort_type_enum NOT NULL
);


--
-- Name: local_site_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.local_site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: local_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.local_site_id_seq OWNED BY public.local_site.id;


--
-- Name: local_site_rate_limit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_site_rate_limit (
    local_site_id integer NOT NULL,
    message integer DEFAULT 180 NOT NULL,
    message_per_second integer DEFAULT 60 NOT NULL,
    post integer DEFAULT 6 NOT NULL,
    post_per_second integer DEFAULT 600 NOT NULL,
    register integer DEFAULT 10 NOT NULL,
    register_per_second integer DEFAULT 3600 NOT NULL,
    image integer DEFAULT 6 NOT NULL,
    image_per_second integer DEFAULT 3600 NOT NULL,
    comment integer DEFAULT 6 NOT NULL,
    comment_per_second integer DEFAULT 600 NOT NULL,
    search integer DEFAULT 60 NOT NULL,
    search_per_second integer DEFAULT 600 NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    import_user_settings integer DEFAULT 1 NOT NULL,
    import_user_settings_per_second integer DEFAULT 86400 NOT NULL
);


--
-- Name: local_site_url_blocklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_site_url_blocklist (
    id integer NOT NULL,
    url text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


--
-- Name: local_site_url_blocklist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.local_site_url_blocklist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: local_site_url_blocklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.local_site_url_blocklist_id_seq OWNED BY public.local_site_url_blocklist.id;


--
-- Name: local_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_user (
    id integer NOT NULL,
    person_id integer NOT NULL,
    password_encrypted text NOT NULL,
    email text,
    show_nsfw boolean DEFAULT false NOT NULL,
    theme text DEFAULT 'browser'::text NOT NULL,
    default_sort_type public.sort_type_enum DEFAULT 'Active'::public.sort_type_enum NOT NULL,
    default_listing_type public.listing_type_enum DEFAULT 'Local'::public.listing_type_enum NOT NULL,
    interface_language character varying(20) DEFAULT 'browser'::character varying NOT NULL,
    show_avatars boolean DEFAULT true NOT NULL,
    send_notifications_to_email boolean DEFAULT false NOT NULL,
    show_scores boolean DEFAULT true NOT NULL,
    show_bot_accounts boolean DEFAULT true NOT NULL,
    show_read_posts boolean DEFAULT true NOT NULL,
    email_verified boolean DEFAULT false NOT NULL,
    accepted_application boolean DEFAULT false NOT NULL,
    totp_2fa_secret text,
    open_links_in_new_tab boolean DEFAULT false NOT NULL,
    blur_nsfw boolean DEFAULT true NOT NULL,
    auto_expand boolean DEFAULT false NOT NULL,
    infinite_scroll_enabled boolean DEFAULT false NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    post_listing_mode public.post_listing_mode_enum DEFAULT 'List'::public.post_listing_mode_enum NOT NULL,
    totp_2fa_enabled boolean DEFAULT false NOT NULL,
    enable_keyboard_navigation boolean DEFAULT false NOT NULL,
    enable_animated_images boolean DEFAULT true NOT NULL,
    collapse_bot_comments boolean DEFAULT false NOT NULL,
    last_donation_notification timestamp with time zone DEFAULT (now() - (random() * '1 year'::interval)) NOT NULL
);


--
-- Name: local_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.local_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: local_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.local_user_id_seq OWNED BY public.local_user.id;


--
-- Name: local_user_language; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_user_language (
    local_user_id integer NOT NULL,
    language_id integer NOT NULL
);


--
-- Name: local_user_vote_display_mode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_user_vote_display_mode (
    local_user_id integer NOT NULL,
    score boolean DEFAULT false NOT NULL,
    upvotes boolean DEFAULT true NOT NULL,
    downvotes boolean DEFAULT true NOT NULL,
    upvote_percentage boolean DEFAULT false NOT NULL
);


--
-- Name: login_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_token (
    token text NOT NULL,
    user_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    ip text,
    user_agent text
);


--
-- Name: mod_add; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_add (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    other_person_id integer NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mod_add_community; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_add_community (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    other_person_id integer NOT NULL,
    community_id integer NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mod_add_community_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_add_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_add_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_add_community_id_seq OWNED BY public.mod_add_community.id;


--
-- Name: mod_add_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_add_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_add_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_add_id_seq OWNED BY public.mod_add.id;


--
-- Name: mod_ban; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_ban (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    other_person_id integer NOT NULL,
    reason text,
    banned boolean DEFAULT true NOT NULL,
    expires timestamp with time zone,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mod_ban_from_community; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_ban_from_community (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    other_person_id integer NOT NULL,
    community_id integer NOT NULL,
    reason text,
    banned boolean DEFAULT true NOT NULL,
    expires timestamp with time zone,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mod_ban_from_community_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_ban_from_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_ban_from_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_ban_from_community_id_seq OWNED BY public.mod_ban_from_community.id;


--
-- Name: mod_ban_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_ban_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_ban_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_ban_id_seq OWNED BY public.mod_ban.id;


--
-- Name: mod_feature_post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_feature_post (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    post_id integer NOT NULL,
    featured boolean DEFAULT true NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL,
    is_featured_community boolean DEFAULT true NOT NULL
);


--
-- Name: mod_hide_community; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_hide_community (
    id integer NOT NULL,
    community_id integer NOT NULL,
    mod_person_id integer NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL,
    reason text,
    hidden boolean DEFAULT false NOT NULL
);


--
-- Name: mod_hide_community_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_hide_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_hide_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_hide_community_id_seq OWNED BY public.mod_hide_community.id;


--
-- Name: mod_lock_post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_lock_post (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    post_id integer NOT NULL,
    locked boolean DEFAULT true NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mod_lock_post_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_lock_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_lock_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_lock_post_id_seq OWNED BY public.mod_lock_post.id;


--
-- Name: mod_remove_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_remove_comment (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    comment_id integer NOT NULL,
    reason text,
    removed boolean DEFAULT true NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mod_remove_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_remove_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_remove_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_remove_comment_id_seq OWNED BY public.mod_remove_comment.id;


--
-- Name: mod_remove_community; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_remove_community (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    community_id integer NOT NULL,
    reason text,
    removed boolean DEFAULT true NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mod_remove_community_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_remove_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_remove_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_remove_community_id_seq OWNED BY public.mod_remove_community.id;


--
-- Name: mod_remove_post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_remove_post (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    post_id integer NOT NULL,
    reason text,
    removed boolean DEFAULT true NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mod_remove_post_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_remove_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_remove_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_remove_post_id_seq OWNED BY public.mod_remove_post.id;


--
-- Name: mod_sticky_post_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_sticky_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_sticky_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_sticky_post_id_seq OWNED BY public.mod_feature_post.id;


--
-- Name: mod_transfer_community; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_transfer_community (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    other_person_id integer NOT NULL,
    community_id integer NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mod_transfer_community_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_transfer_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_transfer_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_transfer_community_id_seq OWNED BY public.mod_transfer_community.id;


--
-- Name: password_reset_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_request (
    id integer NOT NULL,
    token text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    local_user_id integer NOT NULL
);


--
-- Name: password_reset_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.password_reset_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: password_reset_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.password_reset_request_id_seq OWNED BY public.password_reset_request.id;


--
-- Name: person; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    avatar text,
    banned boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    actor_id character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    bio text,
    local boolean DEFAULT true NOT NULL,
    private_key text,
    public_key text NOT NULL,
    last_refreshed_at timestamp with time zone DEFAULT now() NOT NULL,
    banner text,
    deleted boolean DEFAULT false NOT NULL,
    inbox_url character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    shared_inbox_url character varying(255),
    matrix_user_id text,
    bot_account boolean DEFAULT false NOT NULL,
    ban_expires timestamp with time zone,
    instance_id integer NOT NULL
);


--
-- Name: person_aggregates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person_aggregates (
    person_id integer NOT NULL,
    post_count bigint DEFAULT 0 NOT NULL,
    post_score bigint DEFAULT 0 NOT NULL,
    comment_count bigint DEFAULT 0 NOT NULL,
    comment_score bigint DEFAULT 0 NOT NULL
);


--
-- Name: person_ban; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person_ban (
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: person_block; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person_block (
    person_id integer NOT NULL,
    target_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: person_follower; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person_follower (
    person_id integer NOT NULL,
    follower_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    pending boolean NOT NULL
);


--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.person_id_seq OWNED BY public.person.id;


--
-- Name: person_mention; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person_mention (
    id integer NOT NULL,
    recipient_id integer NOT NULL,
    comment_id integer NOT NULL,
    read boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: person_mention_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.person_mention_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: person_mention_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.person_mention_id_seq OWNED BY public.person_mention.id;


--
-- Name: person_post_aggregates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person_post_aggregates (
    person_id integer NOT NULL,
    post_id integer NOT NULL,
    read_comments bigint DEFAULT 0 NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    url character varying(2000),
    body text,
    creator_id integer NOT NULL,
    community_id integer NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    deleted boolean DEFAULT false NOT NULL,
    nsfw boolean DEFAULT false NOT NULL,
    embed_title text,
    embed_description text,
    thumbnail_url text,
    ap_id character varying(255) NOT NULL,
    local boolean DEFAULT true NOT NULL,
    embed_video_url text,
    language_id integer DEFAULT 0 NOT NULL,
    featured_community boolean DEFAULT false NOT NULL,
    featured_local boolean DEFAULT false NOT NULL,
    url_content_type text,
    alt_text text
);


--
-- Name: post_hide; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_hide (
    post_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: post_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_id_seq OWNED BY public.post.id;


--
-- Name: post_like; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_like (
    post_id integer NOT NULL,
    person_id integer NOT NULL,
    score smallint NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: post_read; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_read (
    post_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: post_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_report (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    post_id integer NOT NULL,
    original_post_name character varying(200) NOT NULL,
    original_post_url text,
    original_post_body text,
    reason text NOT NULL,
    resolved boolean DEFAULT false NOT NULL,
    resolver_id integer,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


--
-- Name: post_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_report_id_seq OWNED BY public.post_report.id;


--
-- Name: post_saved; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_saved (
    post_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: private_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.private_message (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    recipient_id integer NOT NULL,
    content text NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    read boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    ap_id character varying(255) NOT NULL,
    local boolean DEFAULT true NOT NULL,
    removed boolean DEFAULT false NOT NULL
);


--
-- Name: private_message_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.private_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: private_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.private_message_id_seq OWNED BY public.private_message.id;


--
-- Name: private_message_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.private_message_report (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    private_message_id integer NOT NULL,
    original_pm_text text NOT NULL,
    reason text NOT NULL,
    resolved boolean DEFAULT false NOT NULL,
    resolver_id integer,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


--
-- Name: private_message_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.private_message_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: private_message_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.private_message_report_id_seq OWNED BY public.private_message_report.id;


--
-- Name: received_activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.received_activity (
    ap_id text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: registration_application; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_application (
    id integer NOT NULL,
    local_user_id integer NOT NULL,
    answer text NOT NULL,
    admin_id integer,
    deny_reason text,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: registration_application_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registration_application_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registration_application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registration_application_id_seq OWNED BY public.registration_application.id;


--
-- Name: remote_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.remote_image (
    link text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: secret; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secret (
    id integer NOT NULL,
    jwt_secret character varying DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: secret_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.secret_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: secret_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.secret_id_seq OWNED BY public.secret.id;


--
-- Name: sent_activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sent_activity (
    id bigint NOT NULL,
    ap_id text NOT NULL,
    data json NOT NULL,
    sensitive boolean NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    send_inboxes text[] NOT NULL,
    send_community_followers_of integer,
    send_all_instances boolean NOT NULL,
    actor_type public.actor_type_enum NOT NULL,
    actor_apub_id text
);


--
-- Name: sent_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sent_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sent_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sent_activity_id_seq OWNED BY public.sent_activity.id;


--
-- Name: site; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    sidebar text,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    icon text,
    banner text,
    description character varying(150),
    actor_id character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    last_refreshed_at timestamp with time zone DEFAULT now() NOT NULL,
    inbox_url character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    private_key text,
    public_key text DEFAULT public.generate_unique_changeme() NOT NULL,
    instance_id integer NOT NULL,
    content_warning text
);


--
-- Name: site_aggregates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_aggregates (
    site_id integer NOT NULL,
    users bigint DEFAULT 1 NOT NULL,
    posts bigint DEFAULT 0 NOT NULL,
    comments bigint DEFAULT 0 NOT NULL,
    communities bigint DEFAULT 0 NOT NULL,
    users_active_day bigint DEFAULT 0 NOT NULL,
    users_active_week bigint DEFAULT 0 NOT NULL,
    users_active_month bigint DEFAULT 0 NOT NULL,
    users_active_half_year bigint DEFAULT 0 NOT NULL
);


--
-- Name: site_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_id_seq OWNED BY public.site.id;


--
-- Name: site_language; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_language (
    site_id integer NOT NULL,
    language_id integer NOT NULL
);


--
-- Name: tagline; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tagline (
    id integer NOT NULL,
    local_site_id integer NOT NULL,
    content text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


--
-- Name: tagline_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tagline_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tagline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tagline_id_seq OWNED BY public.tagline.id;


--
-- Name: deps_saved_ddl; Type: TABLE; Schema: utils; Owner: -
--

CREATE TABLE utils.deps_saved_ddl (
    id integer NOT NULL,
    view_schema character varying(255),
    view_name character varying(255),
    ddl_to_run text
);


--
-- Name: deps_saved_ddl_id_seq; Type: SEQUENCE; Schema: utils; Owner: -
--

CREATE SEQUENCE utils.deps_saved_ddl_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deps_saved_ddl_id_seq; Type: SEQUENCE OWNED BY; Schema: utils; Owner: -
--

ALTER SEQUENCE utils.deps_saved_ddl_id_seq OWNED BY utils.deps_saved_ddl.id;


--
-- Name: admin_purge_comment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_comment ALTER COLUMN id SET DEFAULT nextval('public.admin_purge_comment_id_seq'::regclass);


--
-- Name: admin_purge_community id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_community ALTER COLUMN id SET DEFAULT nextval('public.admin_purge_community_id_seq'::regclass);


--
-- Name: admin_purge_person id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_person ALTER COLUMN id SET DEFAULT nextval('public.admin_purge_person_id_seq'::regclass);


--
-- Name: admin_purge_post id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_post ALTER COLUMN id SET DEFAULT nextval('public.admin_purge_post_id_seq'::regclass);


--
-- Name: comment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment ALTER COLUMN id SET DEFAULT nextval('public.comment_id_seq'::regclass);


--
-- Name: comment_reply id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_reply ALTER COLUMN id SET DEFAULT nextval('public.comment_reply_id_seq'::regclass);


--
-- Name: comment_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_report ALTER COLUMN id SET DEFAULT nextval('public.comment_report_id_seq'::regclass);


--
-- Name: community id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community ALTER COLUMN id SET DEFAULT nextval('public.community_id_seq'::regclass);


--
-- Name: custom_emoji id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_emoji ALTER COLUMN id SET DEFAULT nextval('public.custom_emoji_id_seq'::regclass);


--
-- Name: email_verification id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verification ALTER COLUMN id SET DEFAULT nextval('public.email_verification_id_seq'::regclass);


--
-- Name: instance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance ALTER COLUMN id SET DEFAULT nextval('public.instance_id_seq'::regclass);


--
-- Name: language id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.language ALTER COLUMN id SET DEFAULT nextval('public.language_id_seq'::regclass);


--
-- Name: local_site id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_site ALTER COLUMN id SET DEFAULT nextval('public.local_site_id_seq'::regclass);


--
-- Name: local_site_url_blocklist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_site_url_blocklist ALTER COLUMN id SET DEFAULT nextval('public.local_site_url_blocklist_id_seq'::regclass);


--
-- Name: local_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_user ALTER COLUMN id SET DEFAULT nextval('public.local_user_id_seq'::regclass);


--
-- Name: mod_add id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_add ALTER COLUMN id SET DEFAULT nextval('public.mod_add_id_seq'::regclass);


--
-- Name: mod_add_community id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_add_community ALTER COLUMN id SET DEFAULT nextval('public.mod_add_community_id_seq'::regclass);


--
-- Name: mod_ban id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_ban ALTER COLUMN id SET DEFAULT nextval('public.mod_ban_id_seq'::regclass);


--
-- Name: mod_ban_from_community id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_ban_from_community ALTER COLUMN id SET DEFAULT nextval('public.mod_ban_from_community_id_seq'::regclass);


--
-- Name: mod_feature_post id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_feature_post ALTER COLUMN id SET DEFAULT nextval('public.mod_sticky_post_id_seq'::regclass);


--
-- Name: mod_hide_community id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_hide_community ALTER COLUMN id SET DEFAULT nextval('public.mod_hide_community_id_seq'::regclass);


--
-- Name: mod_lock_post id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_lock_post ALTER COLUMN id SET DEFAULT nextval('public.mod_lock_post_id_seq'::regclass);


--
-- Name: mod_remove_comment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_comment ALTER COLUMN id SET DEFAULT nextval('public.mod_remove_comment_id_seq'::regclass);


--
-- Name: mod_remove_community id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_community ALTER COLUMN id SET DEFAULT nextval('public.mod_remove_community_id_seq'::regclass);


--
-- Name: mod_remove_post id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_post ALTER COLUMN id SET DEFAULT nextval('public.mod_remove_post_id_seq'::regclass);


--
-- Name: mod_transfer_community id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_transfer_community ALTER COLUMN id SET DEFAULT nextval('public.mod_transfer_community_id_seq'::regclass);


--
-- Name: password_reset_request id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_request ALTER COLUMN id SET DEFAULT nextval('public.password_reset_request_id_seq'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT nextval('public.person_id_seq'::regclass);


--
-- Name: person_mention id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_mention ALTER COLUMN id SET DEFAULT nextval('public.person_mention_id_seq'::regclass);


--
-- Name: post id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post ALTER COLUMN id SET DEFAULT nextval('public.post_id_seq'::regclass);


--
-- Name: post_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_report ALTER COLUMN id SET DEFAULT nextval('public.post_report_id_seq'::regclass);


--
-- Name: private_message id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message ALTER COLUMN id SET DEFAULT nextval('public.private_message_id_seq'::regclass);


--
-- Name: private_message_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message_report ALTER COLUMN id SET DEFAULT nextval('public.private_message_report_id_seq'::regclass);


--
-- Name: registration_application id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_application ALTER COLUMN id SET DEFAULT nextval('public.registration_application_id_seq'::regclass);


--
-- Name: secret id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret ALTER COLUMN id SET DEFAULT nextval('public.secret_id_seq'::regclass);


--
-- Name: sent_activity id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_activity ALTER COLUMN id SET DEFAULT nextval('public.sent_activity_id_seq'::regclass);


--
-- Name: site id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site ALTER COLUMN id SET DEFAULT nextval('public.site_id_seq'::regclass);


--
-- Name: tagline id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tagline ALTER COLUMN id SET DEFAULT nextval('public.tagline_id_seq'::regclass);


--
-- Name: deps_saved_ddl id; Type: DEFAULT; Schema: utils; Owner: -
--

ALTER TABLE ONLY utils.deps_saved_ddl ALTER COLUMN id SET DEFAULT nextval('utils.deps_saved_ddl_id_seq'::regclass);


--
-- Name: __diesel_schema_migrations __diesel_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.__diesel_schema_migrations
    ADD CONSTRAINT __diesel_schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: admin_purge_comment admin_purge_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_comment
    ADD CONSTRAINT admin_purge_comment_pkey PRIMARY KEY (id);


--
-- Name: admin_purge_community admin_purge_community_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_community
    ADD CONSTRAINT admin_purge_community_pkey PRIMARY KEY (id);


--
-- Name: admin_purge_person admin_purge_person_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_person
    ADD CONSTRAINT admin_purge_person_pkey PRIMARY KEY (id);


--
-- Name: admin_purge_post admin_purge_post_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_post
    ADD CONSTRAINT admin_purge_post_pkey PRIMARY KEY (id);


--
-- Name: captcha_answer captcha_answer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.captcha_answer
    ADD CONSTRAINT captcha_answer_pkey PRIMARY KEY (uuid);


--
-- Name: comment_aggregates comment_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_aggregates
    ADD CONSTRAINT comment_aggregates_pkey PRIMARY KEY (comment_id);


--
-- Name: comment_like comment_like_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_like
    ADD CONSTRAINT comment_like_pkey PRIMARY KEY (person_id, comment_id);


--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: comment_reply comment_reply_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_reply
    ADD CONSTRAINT comment_reply_pkey PRIMARY KEY (id);


--
-- Name: comment_reply comment_reply_recipient_id_comment_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_reply
    ADD CONSTRAINT comment_reply_recipient_id_comment_id_key UNIQUE (recipient_id, comment_id);


--
-- Name: comment_report comment_report_comment_id_creator_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_report
    ADD CONSTRAINT comment_report_comment_id_creator_id_key UNIQUE (comment_id, creator_id);


--
-- Name: comment_report comment_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_report
    ADD CONSTRAINT comment_report_pkey PRIMARY KEY (id);


--
-- Name: comment_saved comment_saved_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_saved
    ADD CONSTRAINT comment_saved_pkey PRIMARY KEY (person_id, comment_id);


--
-- Name: community_aggregates community_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_aggregates
    ADD CONSTRAINT community_aggregates_pkey PRIMARY KEY (community_id);


--
-- Name: community_block community_block_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_block
    ADD CONSTRAINT community_block_pkey PRIMARY KEY (person_id, community_id);


--
-- Name: community community_featured_url_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_featured_url_key UNIQUE (featured_url);


--
-- Name: community_follower community_follower_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_follower
    ADD CONSTRAINT community_follower_pkey PRIMARY KEY (person_id, community_id);


--
-- Name: community_language community_language_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_language
    ADD CONSTRAINT community_language_pkey PRIMARY KEY (community_id, language_id);


--
-- Name: community_moderator community_moderator_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_moderator
    ADD CONSTRAINT community_moderator_pkey PRIMARY KEY (person_id, community_id);


--
-- Name: community community_moderators_url_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_moderators_url_key UNIQUE (moderators_url);


--
-- Name: community_person_ban community_person_ban_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_person_ban
    ADD CONSTRAINT community_person_ban_pkey PRIMARY KEY (person_id, community_id);


--
-- Name: community community_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_pkey PRIMARY KEY (id);


--
-- Name: custom_emoji custom_emoji_image_url_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_emoji
    ADD CONSTRAINT custom_emoji_image_url_key UNIQUE (image_url);


--
-- Name: custom_emoji_keyword custom_emoji_keyword_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_emoji_keyword
    ADD CONSTRAINT custom_emoji_keyword_pkey PRIMARY KEY (custom_emoji_id, keyword);


--
-- Name: custom_emoji custom_emoji_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_emoji
    ADD CONSTRAINT custom_emoji_pkey PRIMARY KEY (id);


--
-- Name: custom_emoji custom_emoji_shortcode_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_emoji
    ADD CONSTRAINT custom_emoji_shortcode_key UNIQUE (shortcode);


--
-- Name: email_verification email_verification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verification
    ADD CONSTRAINT email_verification_pkey PRIMARY KEY (id);


--
-- Name: federation_allowlist federation_allowlist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federation_allowlist
    ADD CONSTRAINT federation_allowlist_pkey PRIMARY KEY (instance_id);


--
-- Name: federation_blocklist federation_blocklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federation_blocklist
    ADD CONSTRAINT federation_blocklist_pkey PRIMARY KEY (instance_id);


--
-- Name: federation_queue_state federation_queue_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federation_queue_state
    ADD CONSTRAINT federation_queue_state_pkey PRIMARY KEY (instance_id);


--
-- Name: comment idx_comment_ap_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT idx_comment_ap_id UNIQUE (ap_id);


--
-- Name: community idx_community_actor_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT idx_community_actor_id UNIQUE (actor_id);


--
-- Name: community idx_community_followers_url; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT idx_community_followers_url UNIQUE (followers_url);


--
-- Name: person idx_person_actor_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT idx_person_actor_id UNIQUE (actor_id);


--
-- Name: post idx_post_ap_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT idx_post_ap_id UNIQUE (ap_id);


--
-- Name: private_message idx_private_message_ap_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message
    ADD CONSTRAINT idx_private_message_ap_id UNIQUE (ap_id);


--
-- Name: site idx_site_instance_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT idx_site_instance_unique UNIQUE (instance_id);


--
-- Name: image_details image_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_details
    ADD CONSTRAINT image_details_pkey PRIMARY KEY (link);


--
-- Name: local_image image_upload_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_image
    ADD CONSTRAINT image_upload_pkey PRIMARY KEY (pictrs_alias);


--
-- Name: instance_block instance_block_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_block
    ADD CONSTRAINT instance_block_pkey PRIMARY KEY (person_id, instance_id);


--
-- Name: instance instance_domain_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance
    ADD CONSTRAINT instance_domain_key UNIQUE (domain);


--
-- Name: instance instance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance
    ADD CONSTRAINT instance_pkey PRIMARY KEY (id);


--
-- Name: language language_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.language
    ADD CONSTRAINT language_pkey PRIMARY KEY (id);


--
-- Name: local_site local_site_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_site
    ADD CONSTRAINT local_site_pkey PRIMARY KEY (id);


--
-- Name: local_site_rate_limit local_site_rate_limit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_site_rate_limit
    ADD CONSTRAINT local_site_rate_limit_pkey PRIMARY KEY (local_site_id);


--
-- Name: local_site local_site_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_site
    ADD CONSTRAINT local_site_site_id_key UNIQUE (site_id);


--
-- Name: local_site_url_blocklist local_site_url_blocklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_site_url_blocklist
    ADD CONSTRAINT local_site_url_blocklist_pkey PRIMARY KEY (id);


--
-- Name: local_site_url_blocklist local_site_url_blocklist_url_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_site_url_blocklist
    ADD CONSTRAINT local_site_url_blocklist_url_key UNIQUE (url);


--
-- Name: local_user local_user_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_user
    ADD CONSTRAINT local_user_email_key UNIQUE (email);


--
-- Name: local_user_language local_user_language_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_user_language
    ADD CONSTRAINT local_user_language_pkey PRIMARY KEY (local_user_id, language_id);


--
-- Name: local_user local_user_person_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_user
    ADD CONSTRAINT local_user_person_id_key UNIQUE (person_id);


--
-- Name: local_user local_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_user
    ADD CONSTRAINT local_user_pkey PRIMARY KEY (id);


--
-- Name: local_user_vote_display_mode local_user_vote_display_mode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_user_vote_display_mode
    ADD CONSTRAINT local_user_vote_display_mode_pkey PRIMARY KEY (local_user_id);


--
-- Name: login_token login_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_token
    ADD CONSTRAINT login_token_pkey PRIMARY KEY (token);


--
-- Name: mod_add_community mod_add_community_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_add_community
    ADD CONSTRAINT mod_add_community_pkey PRIMARY KEY (id);


--
-- Name: mod_add mod_add_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_add
    ADD CONSTRAINT mod_add_pkey PRIMARY KEY (id);


--
-- Name: mod_ban_from_community mod_ban_from_community_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_ban_from_community
    ADD CONSTRAINT mod_ban_from_community_pkey PRIMARY KEY (id);


--
-- Name: mod_ban mod_ban_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_ban
    ADD CONSTRAINT mod_ban_pkey PRIMARY KEY (id);


--
-- Name: mod_hide_community mod_hide_community_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_hide_community
    ADD CONSTRAINT mod_hide_community_pkey PRIMARY KEY (id);


--
-- Name: mod_lock_post mod_lock_post_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_lock_post
    ADD CONSTRAINT mod_lock_post_pkey PRIMARY KEY (id);


--
-- Name: mod_remove_comment mod_remove_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_comment
    ADD CONSTRAINT mod_remove_comment_pkey PRIMARY KEY (id);


--
-- Name: mod_remove_community mod_remove_community_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_community
    ADD CONSTRAINT mod_remove_community_pkey PRIMARY KEY (id);


--
-- Name: mod_remove_post mod_remove_post_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_post
    ADD CONSTRAINT mod_remove_post_pkey PRIMARY KEY (id);


--
-- Name: mod_feature_post mod_sticky_post_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_feature_post
    ADD CONSTRAINT mod_sticky_post_pkey PRIMARY KEY (id);


--
-- Name: mod_transfer_community mod_transfer_community_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_transfer_community
    ADD CONSTRAINT mod_transfer_community_pkey PRIMARY KEY (id);


--
-- Name: password_reset_request password_reset_request_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_request
    ADD CONSTRAINT password_reset_request_pkey PRIMARY KEY (id);


--
-- Name: person person__pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person__pkey PRIMARY KEY (id);


--
-- Name: person_aggregates person_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_aggregates
    ADD CONSTRAINT person_aggregates_pkey PRIMARY KEY (person_id);


--
-- Name: person_ban person_ban_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_ban
    ADD CONSTRAINT person_ban_pkey PRIMARY KEY (person_id);


--
-- Name: person_block person_block_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_block
    ADD CONSTRAINT person_block_pkey PRIMARY KEY (person_id, target_id);


--
-- Name: person_follower person_follower_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_follower
    ADD CONSTRAINT person_follower_pkey PRIMARY KEY (follower_id, person_id);


--
-- Name: person_mention person_mention_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_mention
    ADD CONSTRAINT person_mention_pkey PRIMARY KEY (id);


--
-- Name: person_mention person_mention_recipient_id_comment_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_mention
    ADD CONSTRAINT person_mention_recipient_id_comment_id_key UNIQUE (recipient_id, comment_id);


--
-- Name: person_post_aggregates person_post_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_post_aggregates
    ADD CONSTRAINT person_post_aggregates_pkey PRIMARY KEY (person_id, post_id);


--
-- Name: post_aggregates post_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_aggregates
    ADD CONSTRAINT post_aggregates_pkey PRIMARY KEY (post_id);


--
-- Name: post_hide post_hide_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_hide
    ADD CONSTRAINT post_hide_pkey PRIMARY KEY (person_id, post_id);


--
-- Name: post_like post_like_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_like
    ADD CONSTRAINT post_like_pkey PRIMARY KEY (person_id, post_id);


--
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_pkey PRIMARY KEY (id);


--
-- Name: post_read post_read_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_read
    ADD CONSTRAINT post_read_pkey PRIMARY KEY (person_id, post_id);


--
-- Name: post_report post_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_report
    ADD CONSTRAINT post_report_pkey PRIMARY KEY (id);


--
-- Name: post_report post_report_post_id_creator_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_report
    ADD CONSTRAINT post_report_post_id_creator_id_key UNIQUE (post_id, creator_id);


--
-- Name: post_saved post_saved_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_saved
    ADD CONSTRAINT post_saved_pkey PRIMARY KEY (person_id, post_id);


--
-- Name: private_message private_message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message
    ADD CONSTRAINT private_message_pkey PRIMARY KEY (id);


--
-- Name: private_message_report private_message_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message_report
    ADD CONSTRAINT private_message_report_pkey PRIMARY KEY (id);


--
-- Name: private_message_report private_message_report_private_message_id_creator_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message_report
    ADD CONSTRAINT private_message_report_private_message_id_creator_id_key UNIQUE (private_message_id, creator_id);


--
-- Name: received_activity received_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.received_activity
    ADD CONSTRAINT received_activity_pkey PRIMARY KEY (ap_id);


--
-- Name: registration_application registration_application_local_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_application
    ADD CONSTRAINT registration_application_local_user_id_key UNIQUE (local_user_id);


--
-- Name: registration_application registration_application_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_application
    ADD CONSTRAINT registration_application_pkey PRIMARY KEY (id);


--
-- Name: remote_image remote_image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remote_image
    ADD CONSTRAINT remote_image_pkey PRIMARY KEY (link);


--
-- Name: secret secret_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret
    ADD CONSTRAINT secret_pkey PRIMARY KEY (id);


--
-- Name: sent_activity sent_activity_ap_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_activity
    ADD CONSTRAINT sent_activity_ap_id_key UNIQUE (ap_id);


--
-- Name: sent_activity sent_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_activity
    ADD CONSTRAINT sent_activity_pkey PRIMARY KEY (id);


--
-- Name: site site_actor_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_actor_id_key UNIQUE (actor_id);


--
-- Name: site_aggregates site_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_aggregates
    ADD CONSTRAINT site_aggregates_pkey PRIMARY KEY (site_id);


--
-- Name: site_language site_language_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_language
    ADD CONSTRAINT site_language_pkey PRIMARY KEY (site_id, language_id);


--
-- Name: site site_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (id);


--
-- Name: tagline tagline_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tagline
    ADD CONSTRAINT tagline_pkey PRIMARY KEY (id);


--
-- Name: deps_saved_ddl deps_saved_ddl_pkey; Type: CONSTRAINT; Schema: utils; Owner: -
--

ALTER TABLE ONLY utils.deps_saved_ddl
    ADD CONSTRAINT deps_saved_ddl_pkey PRIMARY KEY (id);


--
-- Name: idx_comment_aggregates_controversy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_aggregates_controversy ON public.comment_aggregates USING btree (controversy_rank DESC);


--
-- Name: idx_comment_aggregates_hot; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_aggregates_hot ON public.comment_aggregates USING btree (hot_rank DESC, score DESC);


--
-- Name: idx_comment_aggregates_nonzero_hotrank; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_aggregates_nonzero_hotrank ON public.comment_aggregates USING btree (published) WHERE (hot_rank <> (0)::double precision);


--
-- Name: idx_comment_aggregates_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_aggregates_published ON public.comment_aggregates USING btree (published DESC);


--
-- Name: idx_comment_aggregates_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_aggregates_score ON public.comment_aggregates USING btree (score DESC);


--
-- Name: idx_comment_content_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_content_trigram ON public.comment USING gin (content public.gin_trgm_ops);


--
-- Name: idx_comment_creator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_creator ON public.comment USING btree (creator_id);


--
-- Name: idx_comment_language; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_language ON public.comment USING btree (language_id);


--
-- Name: idx_comment_like_comment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_like_comment ON public.comment_like USING btree (comment_id);


--
-- Name: idx_comment_like_post; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_like_post ON public.comment_like USING btree (post_id);


--
-- Name: idx_comment_like_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_like_published ON public.comment_like USING btree (published);


--
-- Name: idx_comment_post; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_post ON public.comment USING btree (post_id);


--
-- Name: idx_comment_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_published ON public.comment USING btree (published DESC);


--
-- Name: idx_comment_reply_comment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_reply_comment ON public.comment_reply USING btree (comment_id);


--
-- Name: idx_comment_reply_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_reply_published ON public.comment_reply USING btree (published DESC);


--
-- Name: idx_comment_reply_recipient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_reply_recipient ON public.comment_reply USING btree (recipient_id);


--
-- Name: idx_comment_report_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_report_published ON public.comment_report USING btree (published DESC);


--
-- Name: idx_comment_saved_comment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_saved_comment ON public.comment_saved USING btree (comment_id);


--
-- Name: idx_comment_saved_person; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comment_saved_person ON public.comment_saved USING btree (person_id);


--
-- Name: idx_community_aggregates_hot; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_aggregates_hot ON public.community_aggregates USING btree (hot_rank DESC);


--
-- Name: idx_community_aggregates_nonzero_hotrank; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_aggregates_nonzero_hotrank ON public.community_aggregates USING btree (published) WHERE (hot_rank <> (0)::double precision);


--
-- Name: idx_community_aggregates_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_aggregates_published ON public.community_aggregates USING btree (published DESC);


--
-- Name: idx_community_aggregates_subscribers; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_aggregates_subscribers ON public.community_aggregates USING btree (subscribers DESC);


--
-- Name: idx_community_aggregates_users_active_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_aggregates_users_active_month ON public.community_aggregates USING btree (users_active_month DESC);


--
-- Name: idx_community_block_community; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_block_community ON public.community_block USING btree (community_id);


--
-- Name: idx_community_follower_community; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_follower_community ON public.community_follower USING btree (community_id);


--
-- Name: idx_community_follower_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_follower_published ON public.community_follower USING btree (published);


--
-- Name: idx_community_lower_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_community_lower_actor_id ON public.community USING btree (lower((actor_id)::text));


--
-- Name: idx_community_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_lower_name ON public.community USING btree (lower((name)::text));


--
-- Name: idx_community_moderator_community; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_moderator_community ON public.community_moderator USING btree (community_id);


--
-- Name: idx_community_moderator_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_moderator_published ON public.community_moderator USING btree (published);


--
-- Name: idx_community_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_published ON public.community USING btree (published DESC);


--
-- Name: idx_community_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_title ON public.community USING btree (title);


--
-- Name: idx_community_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_community_trigram ON public.community USING gin (name public.gin_trgm_ops, title public.gin_trgm_ops);


--
-- Name: idx_custom_emoji_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_custom_emoji_category ON public.custom_emoji USING btree (id, category);


--
-- Name: idx_image_upload_local_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_image_upload_local_user_id ON public.local_image USING btree (local_user_id);


--
-- Name: idx_login_token_user_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_login_token_user_token ON public.login_token USING btree (user_id, token);


--
-- Name: idx_path_gist; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_path_gist ON public.comment USING gist (path);


--
-- Name: idx_person_aggregates_comment_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_person_aggregates_comment_score ON public.person_aggregates USING btree (comment_score DESC);


--
-- Name: idx_person_aggregates_person; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_person_aggregates_person ON public.person_aggregates USING btree (person_id);


--
-- Name: idx_person_block_person; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_person_block_person ON public.person_block USING btree (person_id);


--
-- Name: idx_person_block_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_person_block_target ON public.person_block USING btree (target_id);


--
-- Name: idx_person_local_instance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_person_local_instance ON public.person USING btree (local DESC, instance_id);


--
-- Name: idx_person_lower_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_person_lower_actor_id ON public.person USING btree (lower((actor_id)::text));


--
-- Name: idx_person_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_person_lower_name ON public.person USING btree (lower((name)::text));


--
-- Name: idx_person_post_aggregates_person; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_person_post_aggregates_person ON public.person_post_aggregates USING btree (person_id);


--
-- Name: idx_person_post_aggregates_post; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_person_post_aggregates_post ON public.person_post_aggregates USING btree (post_id);


--
-- Name: idx_person_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_person_published ON public.person USING btree (published DESC);


--
-- Name: idx_person_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_person_trigram ON public.person USING gin (name public.gin_trgm_ops, display_name public.gin_trgm_ops);


--
-- Name: idx_post_aggregates_community; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community ON public.post_aggregates USING btree (community_id);


--
-- Name: idx_post_aggregates_community_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community_active ON public.post_aggregates USING btree (community_id, featured_local DESC, hot_rank_active DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_controversy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community_controversy ON public.post_aggregates USING btree (community_id, featured_local DESC, controversy_rank DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_hot; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community_hot ON public.post_aggregates USING btree (community_id, featured_local DESC, hot_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_most_comments; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community_most_comments ON public.post_aggregates USING btree (community_id, featured_local DESC, comments DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_newest_comment_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community_newest_comment_time ON public.post_aggregates USING btree (community_id, featured_local DESC, newest_comment_time DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_newest_comment_time_necro; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community_newest_comment_time_necro ON public.post_aggregates USING btree (community_id, featured_local DESC, newest_comment_time_necro DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community_published ON public.post_aggregates USING btree (community_id, featured_local DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_published_asc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community_published_asc ON public.post_aggregates USING btree (community_id, featured_local DESC, public.reverse_timestamp_sort(published) DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_scaled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community_scaled ON public.post_aggregates USING btree (community_id, featured_local DESC, scaled_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_community_score ON public.post_aggregates USING btree (community_id, featured_local DESC, score DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_creator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_creator ON public.post_aggregates USING btree (creator_id);


--
-- Name: idx_post_aggregates_featured_community_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_community_active ON public.post_aggregates USING btree (community_id, featured_community DESC, hot_rank_active DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_controversy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_community_controversy ON public.post_aggregates USING btree (community_id, featured_community DESC, controversy_rank DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_hot; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_community_hot ON public.post_aggregates USING btree (community_id, featured_community DESC, hot_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_most_comments; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_community_most_comments ON public.post_aggregates USING btree (community_id, featured_community DESC, comments DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_newest_comment_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_community_newest_comment_time ON public.post_aggregates USING btree (community_id, featured_community DESC, newest_comment_time DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_newest_comment_time_necr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_community_newest_comment_time_necr ON public.post_aggregates USING btree (community_id, featured_community DESC, newest_comment_time_necro DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_community_published ON public.post_aggregates USING btree (community_id, featured_community DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_published_asc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_community_published_asc ON public.post_aggregates USING btree (community_id, featured_community DESC, public.reverse_timestamp_sort(published) DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_scaled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_community_scaled ON public.post_aggregates USING btree (community_id, featured_community DESC, scaled_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_community_score ON public.post_aggregates USING btree (community_id, featured_community DESC, score DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_local_active ON public.post_aggregates USING btree (featured_local DESC, hot_rank_active DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_controversy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_local_controversy ON public.post_aggregates USING btree (featured_local DESC, controversy_rank DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_hot; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_local_hot ON public.post_aggregates USING btree (featured_local DESC, hot_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_most_comments; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_local_most_comments ON public.post_aggregates USING btree (featured_local DESC, comments DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_newest_comment_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_local_newest_comment_time ON public.post_aggregates USING btree (featured_local DESC, newest_comment_time DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_newest_comment_time_necro; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_local_newest_comment_time_necro ON public.post_aggregates USING btree (featured_local DESC, newest_comment_time_necro DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_local_published ON public.post_aggregates USING btree (featured_local DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_published_asc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_local_published_asc ON public.post_aggregates USING btree (featured_local DESC, public.reverse_timestamp_sort(published) DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_scaled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_local_scaled ON public.post_aggregates USING btree (featured_local DESC, scaled_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_featured_local_score ON public.post_aggregates USING btree (featured_local DESC, score DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_nonzero_hotrank; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_nonzero_hotrank ON public.post_aggregates USING btree (published DESC) WHERE ((hot_rank <> (0)::double precision) OR (hot_rank_active <> (0)::double precision));


--
-- Name: idx_post_aggregates_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_published ON public.post_aggregates USING btree (published DESC);


--
-- Name: idx_post_aggregates_published_asc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_aggregates_published_asc ON public.post_aggregates USING btree (public.reverse_timestamp_sort(published) DESC);


--
-- Name: idx_post_community; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_community ON public.post USING btree (community_id);


--
-- Name: idx_post_creator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_creator ON public.post USING btree (creator_id);


--
-- Name: idx_post_hide_post; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_hide_post ON public.post_hide USING btree (post_id);


--
-- Name: idx_post_language; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_language ON public.post USING btree (language_id);


--
-- Name: idx_post_like_post; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_like_post ON public.post_like USING btree (post_id);


--
-- Name: idx_post_like_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_like_published ON public.post_like USING btree (published);


--
-- Name: idx_post_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_published ON public.post USING btree (published);


--
-- Name: idx_post_read_post; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_read_post ON public.post_read USING btree (post_id);


--
-- Name: idx_post_report_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_report_published ON public.post_report USING btree (published DESC);


--
-- Name: idx_post_saved_post; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_saved_post ON public.post_saved USING btree (post_id);


--
-- Name: idx_post_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_trigram ON public.post USING gin (name public.gin_trgm_ops, body public.gin_trgm_ops, alt_text public.gin_trgm_ops);


--
-- Name: idx_post_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_post_url ON public.post USING btree (url);


--
-- Name: idx_registration_application_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_registration_application_published ON public.registration_application USING btree (published DESC);


--
-- Name: idx_site_aggregates_1_row_only; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_site_aggregates_1_row_only ON public.site_aggregates USING btree ((true));


--
-- Name: comment aggregates; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER aggregates AFTER INSERT ON public.comment REFERENCING NEW TABLE AS new_comment FOR EACH STATEMENT EXECUTE FUNCTION r.comment_aggregates_from_comment();


--
-- Name: community aggregates; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER aggregates AFTER INSERT ON public.community REFERENCING NEW TABLE AS new_community FOR EACH STATEMENT EXECUTE FUNCTION r.community_aggregates_from_community();


--
-- Name: person aggregates; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER aggregates AFTER INSERT ON public.person REFERENCING NEW TABLE AS new_person FOR EACH STATEMENT EXECUTE FUNCTION r.person_aggregates_from_person();


--
-- Name: post aggregates; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER aggregates AFTER INSERT ON public.post REFERENCING NEW TABLE AS new_post FOR EACH STATEMENT EXECUTE FUNCTION r.post_aggregates_from_post();


--
-- Name: site aggregates; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER aggregates AFTER INSERT ON public.site FOR EACH ROW EXECUTE FUNCTION r.site_aggregates_from_site();


--
-- Name: post aggregates_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER aggregates_update AFTER UPDATE ON public.post REFERENCING OLD TABLE AS old_post NEW TABLE AS new_post FOR EACH STATEMENT EXECUTE FUNCTION r.post_aggregates_from_post_update();


--
-- Name: comment change_values; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER change_values BEFORE INSERT OR UPDATE ON public.comment FOR EACH ROW EXECUTE FUNCTION r.comment_change_values();


--
-- Name: post change_values; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER change_values BEFORE INSERT ON public.post FOR EACH ROW EXECUTE FUNCTION r.post_change_values();


--
-- Name: private_message change_values; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER change_values BEFORE INSERT ON public.private_message FOR EACH ROW EXECUTE FUNCTION r.private_message_change_values();


--
-- Name: post comment_count; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER comment_count AFTER UPDATE ON public.post REFERENCING OLD TABLE AS old_post NEW TABLE AS new_post FOR EACH STATEMENT EXECUTE FUNCTION r.update_comment_count_from_post();


--
-- Name: post delete_comments; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_comments BEFORE DELETE ON public.post FOR EACH ROW EXECUTE FUNCTION r.delete_comments_before_post();


--
-- Name: person delete_follow; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_follow BEFORE DELETE ON public.person FOR EACH ROW EXECUTE FUNCTION r.delete_follow_before_person();


--
-- Name: comment delete_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.comment REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_delete_statement();


--
-- Name: comment_like delete_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.comment_like REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_like_delete_statement();


--
-- Name: community delete_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.community REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_delete_statement();


--
-- Name: community_follower delete_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.community_follower REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_follower_delete_statement();


--
-- Name: local_user delete_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.local_user REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.local_user_delete_statement();


--
-- Name: post delete_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.post REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_delete_statement();


--
-- Name: post_like delete_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.post_like REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_like_delete_statement();


--
-- Name: comment insert_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.comment REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_insert_statement();


--
-- Name: comment_like insert_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.comment_like REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_like_insert_statement();


--
-- Name: community insert_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.community REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_insert_statement();


--
-- Name: community_follower insert_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.community_follower REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_follower_insert_statement();


--
-- Name: local_user insert_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.local_user REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.local_user_insert_statement();


--
-- Name: post insert_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.post REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_insert_statement();


--
-- Name: post_like insert_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.post_like REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_like_insert_statement();


--
-- Name: comment update_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.comment REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_update_statement();


--
-- Name: comment_like update_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.comment_like REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_like_update_statement();


--
-- Name: community update_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.community REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_update_statement();


--
-- Name: community_follower update_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.community_follower REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_follower_update_statement();


--
-- Name: local_user update_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.local_user REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.local_user_update_statement();


--
-- Name: post update_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.post REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_update_statement();


--
-- Name: post_like update_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.post_like REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_like_update_statement();


--
-- Name: admin_purge_comment admin_purge_comment_admin_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_comment
    ADD CONSTRAINT admin_purge_comment_admin_person_id_fkey FOREIGN KEY (admin_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_purge_comment admin_purge_comment_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_comment
    ADD CONSTRAINT admin_purge_comment_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_purge_community admin_purge_community_admin_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_community
    ADD CONSTRAINT admin_purge_community_admin_person_id_fkey FOREIGN KEY (admin_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_purge_person admin_purge_person_admin_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_person
    ADD CONSTRAINT admin_purge_person_admin_person_id_fkey FOREIGN KEY (admin_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_purge_post admin_purge_post_admin_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_post
    ADD CONSTRAINT admin_purge_post_admin_person_id_fkey FOREIGN KEY (admin_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_purge_post admin_purge_post_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_purge_post
    ADD CONSTRAINT admin_purge_post_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_aggregates comment_aggregates_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_aggregates
    ADD CONSTRAINT comment_aggregates_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: comment comment_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment comment_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id);


--
-- Name: comment_like comment_like_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_like
    ADD CONSTRAINT comment_like_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_like comment_like_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_like
    ADD CONSTRAINT comment_like_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_like comment_like_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_like
    ADD CONSTRAINT comment_like_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment comment_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_reply comment_reply_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_reply
    ADD CONSTRAINT comment_reply_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_reply comment_reply_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_reply
    ADD CONSTRAINT comment_reply_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_report comment_report_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_report
    ADD CONSTRAINT comment_report_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_report comment_report_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_report
    ADD CONSTRAINT comment_report_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_report comment_report_resolver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_report
    ADD CONSTRAINT comment_report_resolver_id_fkey FOREIGN KEY (resolver_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_saved comment_saved_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_saved
    ADD CONSTRAINT comment_saved_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_saved comment_saved_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_saved
    ADD CONSTRAINT comment_saved_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_aggregates community_aggregates_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_aggregates
    ADD CONSTRAINT community_aggregates_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: community_block community_block_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_block
    ADD CONSTRAINT community_block_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_block community_block_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_block
    ADD CONSTRAINT community_block_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_follower community_follower_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_follower
    ADD CONSTRAINT community_follower_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_follower community_follower_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_follower
    ADD CONSTRAINT community_follower_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community community_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_language community_language_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_language
    ADD CONSTRAINT community_language_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_language community_language_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_language
    ADD CONSTRAINT community_language_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_moderator community_moderator_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_moderator
    ADD CONSTRAINT community_moderator_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_moderator community_moderator_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_moderator
    ADD CONSTRAINT community_moderator_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_person_ban community_person_ban_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_person_ban
    ADD CONSTRAINT community_person_ban_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_person_ban community_person_ban_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_person_ban
    ADD CONSTRAINT community_person_ban_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: custom_emoji_keyword custom_emoji_keyword_custom_emoji_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_emoji_keyword
    ADD CONSTRAINT custom_emoji_keyword_custom_emoji_id_fkey FOREIGN KEY (custom_emoji_id) REFERENCES public.custom_emoji(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: custom_emoji custom_emoji_local_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_emoji
    ADD CONSTRAINT custom_emoji_local_site_id_fkey FOREIGN KEY (local_site_id) REFERENCES public.local_site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: email_verification email_verification_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verification
    ADD CONSTRAINT email_verification_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: federation_allowlist federation_allowlist_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federation_allowlist
    ADD CONSTRAINT federation_allowlist_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: federation_blocklist federation_blocklist_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federation_blocklist
    ADD CONSTRAINT federation_blocklist_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: federation_queue_state federation_queue_state_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federation_queue_state
    ADD CONSTRAINT federation_queue_state_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id);


--
-- Name: local_image image_upload_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_image
    ADD CONSTRAINT image_upload_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: instance_block instance_block_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_block
    ADD CONSTRAINT instance_block_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: instance_block instance_block_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_block
    ADD CONSTRAINT instance_block_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_site_rate_limit local_site_rate_limit_local_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_site_rate_limit
    ADD CONSTRAINT local_site_rate_limit_local_site_id_fkey FOREIGN KEY (local_site_id) REFERENCES public.local_site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_site local_site_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_site
    ADD CONSTRAINT local_site_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_user_language local_user_language_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_user_language
    ADD CONSTRAINT local_user_language_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_user_language local_user_language_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_user_language
    ADD CONSTRAINT local_user_language_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_user local_user_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_user
    ADD CONSTRAINT local_user_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_user_vote_display_mode local_user_vote_display_mode_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_user_vote_display_mode
    ADD CONSTRAINT local_user_vote_display_mode_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: login_token login_token_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_token
    ADD CONSTRAINT login_token_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_add_community mod_add_community_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_add_community
    ADD CONSTRAINT mod_add_community_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_add_community mod_add_community_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_add_community
    ADD CONSTRAINT mod_add_community_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_add_community mod_add_community_other_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_add_community
    ADD CONSTRAINT mod_add_community_other_person_id_fkey FOREIGN KEY (other_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_add mod_add_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_add
    ADD CONSTRAINT mod_add_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_add mod_add_other_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_add
    ADD CONSTRAINT mod_add_other_person_id_fkey FOREIGN KEY (other_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_ban_from_community mod_ban_from_community_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_ban_from_community
    ADD CONSTRAINT mod_ban_from_community_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_ban_from_community mod_ban_from_community_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_ban_from_community
    ADD CONSTRAINT mod_ban_from_community_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_ban_from_community mod_ban_from_community_other_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_ban_from_community
    ADD CONSTRAINT mod_ban_from_community_other_person_id_fkey FOREIGN KEY (other_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_ban mod_ban_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_ban
    ADD CONSTRAINT mod_ban_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_ban mod_ban_other_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_ban
    ADD CONSTRAINT mod_ban_other_person_id_fkey FOREIGN KEY (other_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_hide_community mod_hide_community_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_hide_community
    ADD CONSTRAINT mod_hide_community_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_hide_community mod_hide_community_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_hide_community
    ADD CONSTRAINT mod_hide_community_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_lock_post mod_lock_post_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_lock_post
    ADD CONSTRAINT mod_lock_post_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_lock_post mod_lock_post_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_lock_post
    ADD CONSTRAINT mod_lock_post_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_comment mod_remove_comment_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_comment
    ADD CONSTRAINT mod_remove_comment_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_comment mod_remove_comment_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_comment
    ADD CONSTRAINT mod_remove_comment_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_community mod_remove_community_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_community
    ADD CONSTRAINT mod_remove_community_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_community mod_remove_community_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_community
    ADD CONSTRAINT mod_remove_community_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_post mod_remove_post_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_post
    ADD CONSTRAINT mod_remove_post_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_post mod_remove_post_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_remove_post
    ADD CONSTRAINT mod_remove_post_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_feature_post mod_sticky_post_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_feature_post
    ADD CONSTRAINT mod_sticky_post_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_feature_post mod_sticky_post_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_feature_post
    ADD CONSTRAINT mod_sticky_post_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_transfer_community mod_transfer_community_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_transfer_community
    ADD CONSTRAINT mod_transfer_community_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_transfer_community mod_transfer_community_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_transfer_community
    ADD CONSTRAINT mod_transfer_community_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_transfer_community mod_transfer_community_other_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_transfer_community
    ADD CONSTRAINT mod_transfer_community_other_person_id_fkey FOREIGN KEY (other_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: password_reset_request password_reset_request_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_request
    ADD CONSTRAINT password_reset_request_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_aggregates person_aggregates_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_aggregates
    ADD CONSTRAINT person_aggregates_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: person_ban person_ban_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_ban
    ADD CONSTRAINT person_ban_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_block person_block_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_block
    ADD CONSTRAINT person_block_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_block person_block_target_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_block
    ADD CONSTRAINT person_block_target_id_fkey FOREIGN KEY (target_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_follower person_follower_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_follower
    ADD CONSTRAINT person_follower_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_follower person_follower_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_follower
    ADD CONSTRAINT person_follower_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person person_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_mention person_mention_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_mention
    ADD CONSTRAINT person_mention_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_mention person_mention_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_mention
    ADD CONSTRAINT person_mention_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_post_aggregates person_post_aggregates_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_post_aggregates
    ADD CONSTRAINT person_post_aggregates_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_post_aggregates person_post_aggregates_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_post_aggregates
    ADD CONSTRAINT person_post_aggregates_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_aggregates post_aggregates_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_aggregates
    ADD CONSTRAINT post_aggregates_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_aggregates post_aggregates_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_aggregates
    ADD CONSTRAINT post_aggregates_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_aggregates post_aggregates_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_aggregates
    ADD CONSTRAINT post_aggregates_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_aggregates post_aggregates_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_aggregates
    ADD CONSTRAINT post_aggregates_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post post_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post post_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_hide post_hide_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_hide
    ADD CONSTRAINT post_hide_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_hide post_hide_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_hide
    ADD CONSTRAINT post_hide_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post post_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id);


--
-- Name: post_like post_like_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_like
    ADD CONSTRAINT post_like_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_like post_like_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_like
    ADD CONSTRAINT post_like_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_read post_read_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_read
    ADD CONSTRAINT post_read_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_read post_read_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_read
    ADD CONSTRAINT post_read_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_report post_report_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_report
    ADD CONSTRAINT post_report_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_report post_report_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_report
    ADD CONSTRAINT post_report_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_report post_report_resolver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_report
    ADD CONSTRAINT post_report_resolver_id_fkey FOREIGN KEY (resolver_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_saved post_saved_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_saved
    ADD CONSTRAINT post_saved_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_saved post_saved_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_saved
    ADD CONSTRAINT post_saved_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private_message private_message_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message
    ADD CONSTRAINT private_message_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private_message private_message_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message
    ADD CONSTRAINT private_message_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private_message_report private_message_report_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message_report
    ADD CONSTRAINT private_message_report_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private_message_report private_message_report_private_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message_report
    ADD CONSTRAINT private_message_report_private_message_id_fkey FOREIGN KEY (private_message_id) REFERENCES public.private_message(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private_message_report private_message_report_resolver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_message_report
    ADD CONSTRAINT private_message_report_resolver_id_fkey FOREIGN KEY (resolver_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registration_application registration_application_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_application
    ADD CONSTRAINT registration_application_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registration_application registration_application_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_application
    ADD CONSTRAINT registration_application_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: site_aggregates site_aggregates_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_aggregates
    ADD CONSTRAINT site_aggregates_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: site site_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: site_language site_language_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_language
    ADD CONSTRAINT site_language_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: site_language site_language_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_language
    ADD CONSTRAINT site_language_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tagline tagline_local_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tagline
    ADD CONSTRAINT tagline_local_site_id_fkey FOREIGN KEY (local_site_id) REFERENCES public.local_site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


