/*-------------------------------------------------------------------------
 *
 * libpq.c3
 *    This file contains definitions for structures and
 *    externs for functions used by frontend postgres applications.
 *    Based on libpq-fe.h.
 *
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *-------------------------------------------------------------------------
 */

/*
 * Object ID is a fundamental type in Postgres.
 */
distinct Oid = uint;

// #define InvalidOid        (Oid(0))

const uint OID_MAX = uint.max;

macro atooid(x) {
    return (Oid) strtoul((x), NULL, 10);
}

/*
 * Identifiers of error message fields.  Kept here to keep common
 * between frontend and backend, and also to export them to libpq
 * applications.
 */
module postgres::pg;
const char DIAG_SEVERITY = 'S';
const char DIAG_SEVERITY_NONLOCALIZED = 'V';
const char DIAG_SQLSTATE = 'C';
const char DIAG_MESSAGE_PRIMARY = 'M';
const char DIAG_MESSAGE_DETAIL = 'D';
const char DIAG_MESSAGE_HINT = 'H';
const char DIAG_STATEMENT_POSITION = 'P';
const char DIAG_INTERNAL_POSITION = 'p';
const char DIAG_INTERNAL_QUERY = 'q';
const char DIAG_CONTEXT = 'W';
const char DIAG_SCHEMA_NAME = 's';
const char DIAG_TABLE_NAME = 't';
const char DIAG_COLUMN_NAME = 'c';
const char DIAG_DATATYPE_NAME = 'd';
const char DIAG_CONSTRAINT_NAME = 'n';
const char DIAG_SOURCE_FILE = 'F';
const char DIAG_SOURCE_LINE = 'L';
const char DIAG_SOURCE_FUNCTION = 'R';

/*
 * These symbols may be used in compile-time #ifdef tests for the availability
 * of newer libpq features.
 */
/* Indicates presence of PQenterPipelineMode and friends */
const int LIBPQ_HAS_PIPELINING = 1;
/* Indicates presence of PQsetTraceFlags; also new PQtrace output format */
const int LIBPQ_HAS_TRACE_FLAGS = 1;
/* Indicates that PQsslAttribute(NULL, "library") is useful */
const int LIBPQ_HAS_SSL_LIBRARY_DETECTION = 1;

/*
 * Option flags for PQcopyResult
 */
const int COPYRES_ATTRS       = 0x01;
const int COPYRES_TUPLES      = 0x02;    /* Implies PG_COPYRES_ATTRS */
const int COPYRES_EVENTS      = 0x04;
const int COPYRES_NOTICEHOOKS = 0x08;

/* Application-visible enum types */

/*
 * Although it is okay to add to these lists, values which become unused
 * should never be removed, nor should constants be redefined - that would
 * break compatibility with existing code.
 */

enum PGConnStatusType {
    OK,
    BAD,
    /* Non-blocking mode only below here */

    /*
     * The existence of these should never be relied upon - they should only
     * be used for user feedback or similar purposes.
     */
    STARTED,            /* Waiting for connection to be made.  */
    MADE,            /* Connection OK; waiting to send.     */
    AWAITING_RESPONSE,    /* Waiting for a response from the
                                     * postmaster.        */
    AUTH_OK,            /* Received authentication; waiting for
                                 * backend startup. */
    SETENV,            /* This state is no longer used. */
    SSL_STARTUP,        /* Negotiating SSL. */
    NEEDED,            /* Internal state: connect() needed */
    CHECK_WRITABLE,    /* Checking if session is read-write. */
    CONSUME,            /* Consuming any extra messages. */
    GSS_STARTUP,        /* Negotiating GSSAPI. */
    CHECK_TARGET,    /* Checking target server properties. */
    CHECK_STANDBY    /* Checking if server is in standby mode. */
}

enum PostgresPollingStatusType {
    FAILED = 0,
    READING,        /* These two indicate that one may      */
    WRITING,        /* use select before polling again.   */
    OK,
    ACTIVE        /* unused; keep for awhile for backwards
                                 * compatibility */
}

enum PGExecStatusType {
    EMPTY_QUERY = 0,        /* empty query string was executed */
    COMMAND_OK,            /* a query command that doesn't return
                                 * anything was executed properly by the
                                 * backend */
    TUPLES_OK,            /* a query command that returns tuples was
                                 * executed properly by the backend, PGresult
                                 * contains the result tuples */
    COPY_OUT,                /* Copy Out data transfer in progress */
    COPY_IN,                /* Copy In data transfer in progress */
    BAD_RESPONSE,            /* an unexpected response was recv'd from the
                                 * backend */
    NONFATAL_ERROR,        /* notice or warning message */
    FATAL_ERROR,            /* query failed */
    COPY_BOTH,            /* Copy In/Out data transfer in progress */
    SINGLE_TUPLE,            /* single tuple from larger resultset */
    PIPELINE_SYNC,        /* pipeline synchronization point */
    PIPELINE_ABORTED        /* Command didn't run because of an abort
                                 * earlier in a pipeline */
}

enum PGTransactionStatusType {
    IDLE,                /* connection idle */
    ACTIVE,                /* command in progress */
    INTRANS,            /* idle, within transaction block */
    INERROR,            /* idle, within failed transaction */
    UNKNOWN                /* cannot determine status */
}

enum PGVerbosity {
    TERSE,                /* single-line error messages */
    DEFAULT,            /* recommended style */
    VERBOSE,            /* all the facts, ma'am */
    SQLSTATE            /* only error severity and SQLSTATE code */
}

enum PGContextVisibility {
    NEVER,        /* never show CONTEXT field */
    ERRORS,        /* show CONTEXT for errors only (default) */
    ALWAYS        /* always show CONTEXT field */
}

/*
 * PGPing - The ordering of this enum should not be altered because the
 * values are exposed externally via pg_isready.
 */

enum PGPing {
    OK,                    /* server is accepting connections */
    REJECT,                /* server is alive but rejecting connections */
    NO_RESPONSE,            /* could not establish connection */
    NO_ATTEMPT            /* connection not attempted (bad params) */
}

/*
 * PGpipelineStatus - Current status of pipeline mode
 */
enum PGpipelineStatus {
    OFF,
    ON,
    ABORTED
}

/* PGconn encapsulates a connection to the backend.
 * The contents of this struct are not supposed to be known to applications.
 */
def PGconn = void;

/* PGresult encapsulates the result of a query (or more precisely, of a single
 * SQL command --- a query string given to PQsendQuery can contain multiple
 * commands and thus return multiple PGresult objects).
 * The contents of this struct are not supposed to be known to applications.
 */
def PGresult = void;

/* PGcancel encapsulates the information needed to cancel a running
 * query on an existing connection.
 * The contents of this struct are not supposed to be known to applications.
 */
def PGcancel = void;

/* PGnotify represents the occurrence of a NOTIFY message.
 * Ideally this would be an opaque type, but it's so simple that it's
 * unlikely to change.
 * NOTE: in Postgres 6.4 and later, the be_pid is the notifying backend's,
 * whereas in earlier versions it was always your own backend's PID.
 */
struct PGnotify {
    char       *relname;        /* notification condition name */
    int            be_pid;            /* process ID of notifying server process */
    char       *extra;            /* notification parameter */
    /* Fields below here are private to libpq; apps should not use 'em */
    PGnotify *next;        /* list link */
}

/* Function types for notice-handling callbacks */
def PQnoticeReceiver = fn void (void *arg, PGresult *res);
def PQnoticeProcessor = fn void (void *arg, char *message);

/* Print options for PQprint() */
def PQbool = char;

struct PQprintOpt {
    PQbool        header;            /* print output field headings and row count */
    PQbool        align;            /* fill align the fields */
    PQbool        standard;        /* old brain dead format */
    PQbool        html3;            /* output html tables */
    PQbool        expanded;        /* expand tables */
    PQbool        pager;            /* use pager for output if needed */
    char       *fieldSep;        /* field separator */
    char       *tableOpt;        /* insert to HTML <table ...> */
    char       *caption;        /* HTML <caption> */
    char      **fieldName;        /* null terminated array of replacement field
                                 * names */
}

/* ----------------
 * Structure for the conninfo parameter definitions returned by PQconndefaults
 * or PQconninfoParse.
 *
 * All fields except "val" point at static strings which must not be altered.
 * "val" is either NULL or a malloc'd current-value string.  PQconninfoFree()
 * will release both the val strings and the PQconninfoOption array itself.
 * ----------------
 */
struct PQconninfoOption {
    char       *keyword;        /* The keyword of the option            */
    char       *envvar;            /* Fallback environment variable name    */
    char       *compiled;        /* Fallback compiled in default value    */
    char       *val;            /* Option's current value, or NULL         */
    char       *label;            /* Label for field in connect dialog    */
    char       *dispchar;        /* Indicates how to display this field in a
                                 * connect dialog. Values are: "" Display
                                 * entered value as is "*" Password field -
                                 * hide value "D"  Debug option - don't show
                                 * by default */
    int            dispsize;        /* Field size in characters for dialog    */
}

/* ----------------
 * PQArgBlock -- structure for PQfn() arguments
 * ----------------
 */
struct PQArgBlock {
    int            len;
    int            isint;
    union u {
        int           *ptr;        /* can't use void (dec compiler barfs)     */
        int            integer;
    }
}

/* ----------------
 * PGresAttDesc -- Data about a single attribute (column) of a query result
 * ----------------
 */
struct PGresAttDesc {
    char       *name;            /* column name */
    Oid            tableid;        /* source table, if known */
    int            columnid;        /* source column, if known */
    int            format;            /* format code for value (text/binary) */
    Oid            typid;            /* type id */
    int            typlen;            /* type size */
    int            atttypmod;        /* type-specific modifier info */
}

module postgres::pq;
/* ----------------
 * Exported functions of libpq
 * ----------------
 */

/* === in fe-connect.c === */

/* make a new client connection to the backend */
/* Asynchronous (non-blocking) */
extern fn PGconn *pq_connectStart(char *conninfo) @extern("PQconnectStart");
extern fn PGconn *pq_connectStartParams(char **keywords,
                                    char **values, int expand_dbname)
                                    @extern("PQconnectStartParams");
extern fn PostgresPollingStatusType pq_connectPoll(PGconn *conn)
@extern("PQconnectPoll");

/* Synchronous (blocking) */
extern fn PGconn *pq_connectdb(char *conninfo) @extern("PQconnectdb");
extern fn PGconn *pq_connectdbParams(char **keywords,
                                 char **values, int expand_dbname)
                                 @extern("PQconnectdbParams");
extern fn PGconn *pq_setdbLogin(char *pghost, char *pgport,
                            char *pgoptions, char *pgtty,
                            char *dbName,
                            char *login, char *pwd)
                            @extern("PQsetdbLogin");

macro pq_setdb(m_pghost,m_pgport,m_pgopt,m_pgtty,m_dbname) {
    return pq_setdbLogin(m_pghost,m_pgport,
                        m_pgopt, m_pgtty, m_dbname, null, null);
}

/* close the current connection and free the PGconn data structure */
extern fn void pq_finish(PGconn *conn) @extern("PQfinish");

/* get info about connection options known to pq_connectdb */
extern fn PQconninfoOption *pq_conndefaults() @extern("PQconndefaults");

/* parse connection options in same way as pq_connectdb */
extern fn PQconninfoOption *pq_conninfoParse(char *conninfo, char **errmsg)
@extern("PQconninfoParse");

/* return the connection options used by a live connection */
extern fn PQconninfoOption *pq_conninfo(PGconn *conn) @extern("PQconninfo");

/* free the data structure returned by pq_conndefaults() or pq_conninfoParse() */
extern fn void pq_conninfoFree(PQconninfoOption *connOptions)
@extern("PQconninfoFree");

/*
 * close the current connection and reestablish a new one with the same
 * parameters
 */
/* Asynchronous (non-blocking) */
extern fn int    PQresetStart(PGconn *conn) @extern("PQresetStart");
extern fn PostgresPollingStatusType pq_resetPoll(PGconn *conn)
@extern("PQresetPoll");

/* Synchronous (blocking) */
extern fn void pq_reset(PGconn *conn) @extern("PQreset");

/* request a cancel structure */
extern fn PGcancel *pq_getCancel(PGconn *conn) @extern("PQgetCancel");

/* free a cancel structure */
extern fn void pq_freeCancel(PGcancel *cancel) @extern("PQfreeCancel");

/* issue a cancel request */
extern fn int    PQcancel(PGcancel *cancel, char *errbuf, int errbufsize)
@extern("PQcancel");

/* backwards compatible version of PQcancel; not thread-safe */
extern fn int    PQrequestCancel(PGconn *conn) @extern("PQrequestCancel");

/* Accessor functions for PGconn objects */
extern fn char *pq_db(PGconn *conn) @extern("PQdb");
extern fn char *pq_user(PGconn *conn) @extern("PQuser");
extern fn char *pq_pass(PGconn *conn) @extern("PQpass");
extern fn char *pq_host(PGconn *conn) @extern("PQhost");
extern fn char *pq_hostaddr(PGconn *conn) @extern("PQhostaddr");
extern fn char *pq_port(PGconn *conn) @extern("PQport");
extern fn char *pq_tty(PGconn *conn) @extern("PQtty");
extern fn char *pq_options(PGconn *conn) @extern("PQoptions");
extern fn PGConnStatusType pq_status(PGconn *conn) @extern("PQstatus");
extern fn PGTransactionStatusType pq_transactionStatus(PGconn *conn)
@extern("PQtransactionStatus");
extern fn char *pq_parameterStatus(PGconn *conn,
                                     char *paramName)
                                     @extern("PQparameterStatus");
extern fn int    PQprotocolVersion(PGconn *conn) @extern("PQprotocolVersion");
extern fn int    PQserverVersion(PGconn *conn) @extern("PQserverVersion");
extern fn char *PQerrorMessage(PGconn *conn) @extern("PQerrorMessage");
extern fn int    PQsocket(PGconn *conn) @extern("PQsocket");
extern fn int    PQbackendPID(PGconn *conn) @extern("PQbackendPID");
extern fn PGpipelineStatus PQpipelineStatus(PGconn *conn)
@extern("PQpipelineStatus");
extern fn int    PQconnectionNeedsPassword(PGconn *conn)
@extern("PQconnectionNeedsPassword");
extern fn int    PQconnectionUsedPassword(PGconn *conn)
@extern("PQconnectionUsedPassword");
extern fn int    PQconnectionUsedGSSAPI(PGconn *conn)
@extern("PQconnectionUsedGSSAPI");
extern fn int    PQclientEncoding(PGconn *conn) @extern("PQclientEncoding");
extern fn int    PQsetClientEncoding(PGconn *conn, char *encoding)
@extern("PQsetClientEncoding");

/* SSL information functions */
extern fn int    PQsslInUse(PGconn *conn) @extern("PQsslInUse");
extern fn void *PQsslStruct(PGconn *conn, char *struct_name)
@extern("PQsslStruct");
extern fn char *PQsslAttribute(PGconn *conn, char *attribute_name)
@extern("PQsslAttribute");
extern fn char **PQsslAttributeNames(PGconn *conn) @extern("PQsslAttributeNames");

/* Get the OpenSSL structure associated with a connection. Returns NULL for
 * unencrypted connections or if any other TLS library is in use. */
extern fn void *PQgetssl(PGconn *conn) @extern("PQgetssl");

/* Tell libpq whether it needs to initialize OpenSSL */
extern fn void PQinitSSL(int do_init) @extern("PQinitSSL");

/* More detailed way to tell libpq whether it needs to initialize OpenSSL */
extern fn void PQinitOpenSSL(int do_ssl, int do_crypto)
@extern("PQinitOpenSSL");

/* Return true if GSSAPI encryption is in use */
extern fn int    PQgssEncInUse(PGconn *conn) @extern("PQgssEncInUse");

/* Returns GSSAPI context if GSSAPI is in use */
extern fn void *PQgetgssctx(PGconn *conn) @extern("PQgetgssctx");

/* Set verbosity for PQerrorMessage and PQresultErrorMessage */
extern fn PGVerbosity PQsetErrorVerbosity(PGconn *conn, PGVerbosity verbosity)
@extern("PQsetErrorVerbosity");

/* Set CONTEXT visibility for PQerrorMessage and PQresultErrorMessage */
extern fn PGContextVisibility PQsetErrorContextVisibility(PGconn *conn,
                                                       PGContextVisibility
                                                       show_context)
                                                       @extern("PQsetErrorContextVisibility");

/* Override default notice handling routines */
extern fn PQnoticeReceiver PQsetNoticeReceiver(PGconn *conn,
                                            PQnoticeReceiver proc,
                                            void *arg)
                                            @extern("PQsetNoticeReceiver");
extern fn PQnoticeProcessor PQsetNoticeProcessor(PGconn *conn,
                                              PQnoticeProcessor proc,
                                              void *arg)
                                              @extern("PQsetNoticeProcessor");

/*
 *       Used to set callback that prevents concurrent access to
 *       non-thread safe functions that libpq needs.
 *       The default implementation uses a libpq internal mutex.
 *       Only required for multithreaded apps that use kerberos
 *       both within their app and for postgresql connections.
 */
def PGthreadlock_t = fn void (int acquire);
extern fn PGthreadlock_t PQregisterThreadLock(PGthreadlock_t newhandler)
@extern("PQregisterThreadLock");

/* === in fe-trace.c === */
extern fn void PQtrace(PGconn *conn, FILE *debug_port) @extern("PQtrace");
extern fn void PQuntrace(PGconn *conn) @extern("PQuntrace");

/* flags controlling trace output: */
/* omit timestamps from each line */
const int TRACE_SUPPRESS_TIMESTAMPS = (1<<0);
/* redact portions of some messages, for testing frameworks */
const int TRACE_REGRESS_MODE = (1<<1);
extern fn void PQsetTraceFlags(PGconn *conn, int flags)
@extern("PQsetTraceFlags");

/* === in fe-exec.c === */

/* Simple synchronous query */
extern fn PGresult *PQexec(PGconn *conn, char *query) @extern("PQexec");
extern fn PGresult *PQexecParams(PGconn *conn,
                              char *command,
                              int nParams,
                              Oid *paramTypes,
                              char **paramValues,
                              int *paramLengths,
                              int *paramFormats,
                              int resultFormat) @extern("PQexecParams");
extern fn PGresult *PQprepare(PGconn *conn, char *stmtName,
                           char *query, int nParams,
                           Oid *paramTypes) @extern("PQprepare");
extern fn PGresult *PQexecPrepared(PGconn *conn,
                                char *stmtName,
                                int nParams,
                                char **paramValues,
                                int *paramLengths,
                                int *paramFormats,
                                int resultFormat) @extern("PQexecPrepared");

/* Interface for multiple-result or asynchronous queries */
const int QUERY_PARAM_MAX_LIMIT = 65535;

extern fn int    PQsendQuery(PGconn *conn, char *query) @extern("PQsendQuery");
extern fn int    PQsendQueryParams(PGconn *conn,
                              char *command,
                              int nParams,
                              Oid *paramTypes,
                              char **paramValues,
                              int *paramLengths,
                              int *paramFormats,
                              int resultFormat) @extern("PQsendQueryParams");
extern fn int    PQsendPrepare(PGconn *conn, char *stmtName,
                          char *query, int nParams,
                          Oid *paramTypes) @extern("PQsendPrepare");
extern fn int    PQsendQueryPrepared(PGconn *conn,
                                char *stmtName,
                                int nParams,
                                char **paramValues,
                                int *paramLengths,
                                int *paramFormats,
                                int resultFormat)
                                @extern("PQsendQueryPrepared");
extern fn int    PQsetSingleRowMode(PGconn *conn) @extern("PQsetSingleRowMode");
extern fn PGresult *PQgetResult(PGconn *conn) @extern("PQgetResult");

/* Routines for managing an asynchronous query */
extern fn int    PQisBusy(PGconn *conn) @extern("PQisBusy");
extern fn int    PQconsumeInput(PGconn *conn) @extern("PQconsumeInput");

/* Routines for pipeline mode management */
extern fn int    PQenterPipelineMode(PGconn *conn)
@extern("PQenterPipelineMode");
extern fn int    PQexitPipelineMode(PGconn *conn) @extern("PQexitPipelineMode");
extern fn int    PQpipelineSync(PGconn *conn) @extern("PQpipelineSync");
extern fn int    PQsendFlushRequest(PGconn *conn) @extern("PQsendFlushRequest");

/* LISTEN/NOTIFY support */
extern fn PGnotify *PQnotifies(PGconn *conn) @extern("PQnotifies");

/* Routines for copy in/out */
extern fn int    PQputCopyData(PGconn *conn, char *buffer, int nbytes)
@extern("PQputCopyData");
extern fn int    PQputCopyEnd(PGconn *conn, char *errormsg)
@extern("PQputCopyEnd");
extern fn int    PQgetCopyData(PGconn *conn, char **buffer, int async)
@extern("PQgetCopyData");

/* Deprecated routines for copy in/out */
extern fn int    PQgetline(PGconn *conn, char *buffer, int length)
@extern("PQgetline");
extern fn int    PQputline(PGconn *conn, char *string) @extern("PQputline");
extern fn int    PQgetlineAsync(PGconn *conn, char *buffer, int bufsize)
@extern("PQgetlineAsync");
extern fn int    PQputnbytes(PGconn *conn, char *buffer, int nbytes)
@extern("PQputnbytes");
extern fn int    PQendcopy(PGconn *conn) @extern("PQendcopy");

/* Set blocking/nonblocking connection to the backend */
extern fn int    PQsetnonblocking(PGconn *conn, int arg)
@extern("PQsetnonblocking");
extern fn int    PQisnonblocking(PGconn *conn) @extern("PQisnonblocking");
extern fn int    PQisthreadsafe() @extern("PQisthreadsafe");
extern fn PGPing PQping(char *conninfo) @extern("PQping");
extern fn PGPing PQpingParams(char **keywords,
                           char **values, int expand_dbname)
                           @extern("PQpingParams");

/* Force the write buffer to be written (or at least try) */
extern fn int    PQflush(PGconn *conn) @extern("PQflush");

/*
 * "Fast path" interface --- not really recommended for application
 * use
 */
extern fn PGresult *PQfn(PGconn *conn,
                      int fnid,
                      int *result_buf,
                      int *result_len,
                      int result_is_int,
                      PQArgBlock *args,
                      int nargs) @extern("PQfn");

/* Accessor functions for PGresult objects */
extern fn PGExecStatusType PQresultStatus(PGresult *res)
@extern("PQresultStatus");
extern fn char *PQresStatus(PGExecStatusType status) @extern("PQresStatus");
extern fn char *PQresultErrorMessage(PGresult *res)
@extern("PQresultErrorMessage");
extern fn char *PQresultVerboseErrorMessage(PGresult *res,
                                         PGVerbosity verbosity,
                                         PGContextVisibility show_context)
                                         @extern("PQresultVerboseErrorMessage");
extern fn char *PQresultErrorField(PGresult *res, int fieldcode)
@extern("PQresultErrorField");
extern fn int    PQntuples(PGresult *res) @extern("PQntuples");
extern fn int    PQnfields(PGresult *res) @extern("PQnfields");
extern fn int    PQbinaryTuples(PGresult *res) @extern("PQbinaryTuples");
extern fn char *PQfname(PGresult *res, int field_num) @extern("PQfname");
extern fn int    PQfnumber(PGresult *res, const char *field_name)
@extern("PQfnumber");
extern fn Oid    PQftable(PGresult *res, int field_num) @extern("PQftable");
extern fn int    PQftablecol(PGresult *res, int field_num)
@extern("PQftablecol");
extern fn int    PQfformat(PGresult *res, int field_num) @extern("PQfformat");
extern fn Oid    PQftype(PGresult *res, int field_num) @extern("PQftype");
extern fn int    PQfsize(PGresult *res, int field_num) @extern("PQfsize");
extern fn int    PQfmod(PGresult *res, int field_num) @extern("PQfmod");
extern fn char *PQcmdStatus(PGresult *res) @extern("PQcmdStatus");
extern fn char *PQoidStatus(PGresult *res)  @extern("PQoidStatus");   /* old and ugly */
extern fn Oid    PQoidValue(PGresult *res)  @extern("PQoidValue");   /* new and improved */
extern fn char *PQcmdTuples(PGresult *res) @extern("PQcmdTuples");
extern fn char *PQgetvalue(PGresult *res, int tup_num, int field_num)
@extern("PQgetvalue");
extern fn int    PQgetlength(PGresult *res, int tup_num, int field_num)
@extern("PQgetlength");
extern fn int    PQgetisnull(PGresult *res, int tup_num, int field_num)
@extern("PQgetisnull");
extern fn int    PQnparams(PGresult *res) @extern("PQnparams");
extern fn Oid    PQparamtype(PGresult *res, int param_num)
@extern("PQparamtype");

/* Describe prepared statements and portals */
extern fn PGresult *PQdescribePrepared(PGconn *conn, char *stmt)
@extern("PQdescribePrepared");
extern fn PGresult *PQdescribePortal(PGconn *conn, char *portal)
@extern("PQdescribePortal");
extern fn int    PQsendDescribePrepared(PGconn *conn, char *stmt)
@extern("PQsendDescribePrepared");
extern fn int    PQsendDescribePortal(PGconn *conn, char *portal)
@extern("PQsendDescribePortal");

/* Delete a PGresult */
extern fn void PQclear(PGresult *res) @extern("PQclear");

/* For freeing other alloc'd results, such as PGnotify structs */
extern fn void PQfreemem(void *ptr) @extern("PQfreemem");

/* Exists for backward compatibility.  bjm 2003-03-24 */
macro PQfreeNotify(ptr) {
    return PQfreemem(ptr);
}

/* Error when no password was given. */
/* Note: depending on this is deprecated; use PQconnectionNeedsPassword(). */
const char *PQnoPasswordSupplied = "fe_sendauth: no password supplied\n";

/* Create and manipulate PGresults */
extern fn PGresult *PQmakeEmptyPGresult(PGconn *conn, PGExecStatusType status)
@extern("PQmakeEmptyPGresult");
extern fn PGresult *PQcopyResult(PGresult *src, int flags)
@extern("PQcopyResult");
extern fn int    PQsetResultAttrs(PGresult *res, int numAttributes, PGresAttDesc
*attDescs) @extern("PQsetResultAttrs");
extern fn void *PQresultAlloc(PGresult *res, size_t nBytes)
@extern("PQresultAlloc");
extern fn size_t PQresultMemorySize(PGresult *res)
@extern("PQresultMemorySize");
extern fn int    PQsetvalue(PGresult *res, int tup_num, int field_num, char
*value, int len) @extern("PQsetvalue");

/* Quoting strings before inclusion in queries. */
extern fn size_t PQescapeStringConn(PGconn *conn,
                                 char *to, char *from, size_t length,
                                 int *error) @extern("PQescapeStringConn");
extern fn char *PQescapeLiteral(PGconn *conn, char *str, size_t len)
@extern("PQescapeLiteral");
extern fn char *PQescapeIdentifier(PGconn *conn, char *str, size_t len)
@extern("PQescapeIdentifier");
extern fn char *PQescapeByteaConn(PGconn *conn,
                                        char *from, size_t from_length,
                                        size_t *to_length)
                                        @extern("PQescapeByteaConn");
extern fn char *PQunescapeBytea(char *strtext,
                                      size_t *retbuflen)
                                      @extern("PQunescapeBytea");

/* These forms are deprecated! */
extern fn size_t PQescapeString(char *to, char *from, size_t length)
@extern("PQescapeString");
extern fn char *PQescapeBytea(char *from, size_t from_length,
                                    size_t *to_length) @extern("PQescapeBytea");



/* === in fe-print.c === */

extern fn void PQprint(FILE *fout, /* output stream */
                    PGresult *res,
                    PQprintOpt *po)  @extern("PQprint");   /* option structure */

/*
 * really old printing routines
 */
extern fn void PQdisplayTuples(PGresult *res,
                            FILE *fp,    /* where to send the output */
                            int fillAlign,    /* pad the fields with spaces */
                            char *fieldSep,    /* field separator */
                            int printHeader,    /* display headers? */
                            int quiet) @extern("PQdisplayTuples");

extern fn void PQprintTuples(PGresult *res,
                          FILE *fout,    /* output stream */
                          int PrintAttNames,    /* print attribute names */
                          int TerseOutput,    /* delimiter bars */
                          int colWidth)  @extern("PQprintTuples");   /* width of column, if 0, use
                                             * variable width */


/* === in fe-lobj.c === */

/* Large-object access routines */
extern fn int    lo_open(PGconn *conn, Oid lobjId, int mode) @extern("lo_open");
extern fn int    lo_close(PGconn *conn, int fd) @extern("lo_close");
extern fn int    lo_read(PGconn *conn, int fd, char *buf, size_t len)
@extern("lo_read");
extern fn int    lo_write(PGconn *conn, int fd, char *buf, size_t len)
@extern("lo_write");
extern fn int    lo_lseek(PGconn *conn, int fd, int offset, int whence)
@extern("lo_lseek");
extern fn long lo_lseek64(PGconn *conn, int fd, long offset, int whence)
@extern("lo_lseek64");
extern fn Oid    lo_creat(PGconn *conn, int mode) @extern("lo_creat");
extern fn Oid    lo_create(PGconn *conn, Oid lobjId) @extern("lo_create");
extern fn int    lo_tell(PGconn *conn, int fd) @extern("lo_tell");
extern fn long lo_tell64(PGconn *conn, int fd) @extern("lo_tell64");
extern fn int    lo_truncate(PGconn *conn, int fd, size_t len)
@extern("lo_truncate");
extern fn int    lo_truncate64(PGconn *conn, int fd, long len)
@extern("lo_truncate64");
extern fn int    lo_unlink(PGconn *conn, Oid lobjId) @extern("lo_unlink");
extern fn Oid    lo_import(PGconn *conn, char *filename) @extern("lo_import");
extern fn Oid    lo_import_with_oid(PGconn *conn, char *filename, Oid lobjId)
@extern("lo_import_with_oid");
extern fn int    lo_export(PGconn *conn, Oid lobjId, char *filename)
@extern("lo_export");

/* === in fe-misc.c === */

/* Get the version of the libpq library in use */
extern fn int    PQlibVersion() @extern("PQlibVersion");

/* Determine length of multibyte encoded char at *s */
extern fn int    PQmblen(char *s, int encoding) @extern("PQmblen");

/* Same, but not more than the distance to the end of string s */
extern fn int    PQmblenBounded(char *s, int encoding)
@extern("PQmblenBounded");

/* Determine display length of multibyte encoded char at *s */
extern fn int    PQdsplen(char *s, int encoding) @extern("PQdsplen");

/* Get encoding id from environment variable PGCLIENTENCODING */
extern fn int    PQenv2encoding() @extern("PQenv2encoding");

/* === in fe-auth.c === */

extern fn char *PQencryptPassword(char *passwd, const char *user)
@extern("PQencryptPassword");
extern fn char *PQencryptPasswordConn(PGconn *conn, char *passwd, const char
*user, const char *algorithm) @extern("PQencryptPasswordConn");

/* === in encnames.c === */

extern fn int    pg_char_to_encoding(char *name) @extern("pg_char_to_encoding");
extern fn char *pg_encoding_to_char(int encoding)
@extern("pg_encoding_to_char");
extern fn int    pg_valid_server_encoding_id(int encoding)
@extern("pg_valid_server_encoding_id");

/* === in fe-secure-openssl.c === */

/* Support for overriding sslpassword handling with a callback */
def PQsslKeyPassHook_OpenSSL_type = fn int (char *buf, int size, PGconn *conn);
extern fn PQsslKeyPassHook_OpenSSL_type PQgetSSLKeyPassHook_OpenSSL()
@extern("PQgetSSLKeyPassHook_OpenSSL");
extern fn void PQsetSSLKeyPassHook_OpenSSL(PQsslKeyPassHook_OpenSSL_type hook)
@extern("PQsetSSLKeyPassHook_OpenSSL");
extern fn int    PQdefaultSSLKeyPassHook_OpenSSL(char *buf, int size, PGconn
*conn) @extern("PQdefaultSSLKeyPassHook_OpenSSL");
