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
 * Ideally this would be an opaque typedef, but it's so simple that it's
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
extern fn PGconn *PQconnectStart(char *conninfo);
extern fn PGconn *PQconnectStartParams(char *const *keywords,
                                    char *const *values, int expand_dbname);
extern fn PostgresPollingStatusType PQconnectPoll(PGconn *conn);

/* Synchronous (blocking) */
extern fn PGconn *PQconnectdb(char *conninfo);
extern fn PGconn *PQconnectdbParams(char *const *keywords,
                                 char *const *values, int expand_dbname);
extern fn PGconn *PQsetdbLogin(char *pghost, const char *pgport,
                            char *pgoptions, const char *pgtty,
                            char *dbName,
                            char *login, const char *pwd);

macro PQsetdb(m_pghost,m_pgport,m_pgopt,m_pgtty,m_dbname) {
    return PQsetdbLogin(m_pghost,m_pgport,
                        m_pgopt, m_pgtty, m_dbname, null, null);
}

/* close the current connection and free the PGconn data structure */
extern fn void PQfinish(PGconn *conn);

/* get info about connection options known to PQconnectdb */
extern fn PQconninfoOption *PQconndefaults();

/* parse connection options in same way as PQconnectdb */
extern fn PQconninfoOption *PQconninfoParse(char *conninfo, char **errmsg);

/* return the connection options used by a live connection */
extern fn PQconninfoOption *PQconninfo(PGconn *conn);

/* free the data structure returned by PQconndefaults() or PQconninfoParse() */
extern fn void PQconninfoFree(PQconninfoOption *connOptions);

/*
 * close the current connection and reestablish a new one with the same
 * parameters
 */
/* Asynchronous (non-blocking) */
extern fn int    PQresetStart(PGconn *conn);
extern fn PostgresPollingStatusType PQresetPoll(PGconn *conn);

/* Synchronous (blocking) */
extern fn void PQreset(PGconn *conn);

/* request a cancel structure */
extern fn PGcancel *PQgetCancel(PGconn *conn);

/* free a cancel structure */
extern fn void PQfreeCancel(PGcancel *cancel);

/* issue a cancel request */
extern fn int    PQcancel(PGcancel *cancel, char *errbuf, int errbufsize);

/* backwards compatible version of PQcancel; not thread-safe */
extern fn int    PQrequestCancel(PGconn *conn);

/* Accessor functions for PGconn objects */
extern fn char *PQdb(PGconn *conn);
extern fn char *PQuser(PGconn *conn);
extern fn char *PQpass(PGconn *conn);
extern fn char *PQhost(PGconn *conn);
extern fn char *PQhostaddr(PGconn *conn);
extern fn char *PQport(PGconn *conn);
extern fn char *PQtty(PGconn *conn);
extern fn char *PQoptions(PGconn *conn);
extern fn PGConnStatusType PQstatus(PGconn *conn);
extern fn PGTransactionStatusType PQtransactionStatus(PGconn *conn);
extern fn char *PQparameterStatus(const PGconn *conn,
                                     char *paramName);
extern fn int    PQprotocolVersion(PGconn *conn);
extern fn int    PQserverVersion(PGconn *conn);
extern fn char *PQerrorMessage(PGconn *conn);
extern fn int    PQsocket(PGconn *conn);
extern fn int    PQbackendPID(PGconn *conn);
extern fn PGpipelineStatus PQpipelineStatus(PGconn *conn);
extern fn int    PQconnectionNeedsPassword(PGconn *conn);
extern fn int    PQconnectionUsedPassword(PGconn *conn);
extern fn int    PQconnectionUsedGSSAPI(PGconn *conn);
extern fn int    PQclientEncoding(PGconn *conn);
extern fn int    PQsetClientEncoding(PGconn *conn, char *encoding);

/* SSL information functions */
extern fn int    PQsslInUse(PGconn *conn);
extern fn void *PQsslStruct(PGconn *conn, char *struct_name);
extern fn char *PQsslAttribute(PGconn *conn, const char *attribute_name);
extern fn char *const *PQsslAttributeNames(PGconn *conn);

/* Get the OpenSSL structure associated with a connection. Returns NULL for
 * unencrypted connections or if any other TLS library is in use. */
extern fn void *PQgetssl(PGconn *conn);

/* Tell libpq whether it needs to initialize OpenSSL */
extern fn void PQinitSSL(int do_init);

/* More detailed way to tell libpq whether it needs to initialize OpenSSL */
extern fn void PQinitOpenSSL(int do_ssl, int do_crypto);

/* Return true if GSSAPI encryption is in use */
extern fn int    PQgssEncInUse(PGconn *conn);

/* Returns GSSAPI context if GSSAPI is in use */
extern fn void *PQgetgssctx(PGconn *conn);

/* Set verbosity for PQerrorMessage and PQresultErrorMessage */
extern fn PGVerbosity PQsetErrorVerbosity(PGconn *conn, PGVerbosity verbosity);

/* Set CONTEXT visibility for PQerrorMessage and PQresultErrorMessage */
extern fn PGContextVisibility PQsetErrorContextVisibility(PGconn *conn,
                                                       PGContextVisibility show_context);

/* Override default notice handling routines */
extern fn PQnoticeReceiver PQsetNoticeReceiver(PGconn *conn,
                                            PQnoticeReceiver proc,
                                            void *arg);
extern fn PQnoticeProcessor PQsetNoticeProcessor(PGconn *conn,
                                              PQnoticeProcessor proc,
                                              void *arg);

/*
 *       Used to set callback that prevents concurrent access to
 *       non-thread safe functions that libpq needs.
 *       The default implementation uses a libpq internal mutex.
 *       Only required for multithreaded apps that use kerberos
 *       both within their app and for postgresql connections.
 */
def PGthreadlock_t = fn void (int acquire);
extern fn PGthreadlock_t PQregisterThreadLock(PGthreadlock_t newhandler);

/* === in fe-trace.c === */
extern fn void PQtrace(PGconn *conn, FILE *debug_port);
extern fn void PQuntrace(PGconn *conn);

/* flags controlling trace output: */
/* omit timestamps from each line */
const int TRACE_SUPPRESS_TIMESTAMPS = (1<<0);
/* redact portions of some messages, for testing frameworks */
const int TRACE_REGRESS_MODE = (1<<1);
extern fn void PQsetTraceFlags(PGconn *conn, int flags);

/* === in fe-exec.c === */

/* Simple synchronous query */
extern fn PGresult *PQexec(PGconn *conn, char *query);
extern fn PGresult *PQexecParams(PGconn *conn,
                              char *command,
                              int nParams,
                              Oid *paramTypes,
                              char *const *paramValues,
                              int *paramLengths,
                              int *paramFormats,
                              int resultFormat);
extern fn PGresult *PQprepare(PGconn *conn, char *stmtName,
                           char *query, int nParams,
                           Oid *paramTypes);
extern fn PGresult *PQexecPrepared(PGconn *conn,
                                char *stmtName,
                                int nParams,
                                char *const *paramValues,
                                int *paramLengths,
                                int *paramFormats,
                                int resultFormat);

/* Interface for multiple-result or asynchronous queries */
const int QUERY_PARAM_MAX_LIMIT = 65535;

extern fn int    PQsendQuery(PGconn *conn, char *query);
extern fn int    PQsendQueryParams(PGconn *conn,
                              char *command,
                              int nParams,
                              Oid *paramTypes,
                              char *const *paramValues,
                              int *paramLengths,
                              int *paramFormats,
                              int resultFormat);
extern fn int    PQsendPrepare(PGconn *conn, char *stmtName,
                          char *query, int nParams,
                          Oid *paramTypes);
extern fn int    PQsendQueryPrepared(PGconn *conn,
                                char *stmtName,
                                int nParams,
                                char *const *paramValues,
                                int *paramLengths,
                                int *paramFormats,
                                int resultFormat);
extern fn int    PQsetSingleRowMode(PGconn *conn);
extern fn PGresult *PQgetResult(PGconn *conn);

/* Routines for managing an asynchronous query */
extern fn int    PQisBusy(PGconn *conn);
extern fn int    PQconsumeInput(PGconn *conn);

/* Routines for pipeline mode management */
extern fn int    PQenterPipelineMode(PGconn *conn);
extern fn int    PQexitPipelineMode(PGconn *conn);
extern fn int    PQpipelineSync(PGconn *conn);
extern fn int    PQsendFlushRequest(PGconn *conn);

/* LISTEN/NOTIFY support */
extern fn PGnotify *PQnotifies(PGconn *conn);

/* Routines for copy in/out */
extern fn int    PQputCopyData(PGconn *conn, char *buffer, int nbytes);
extern fn int    PQputCopyEnd(PGconn *conn, char *errormsg);
extern fn int    PQgetCopyData(PGconn *conn, char **buffer, int async);

/* Deprecated routines for copy in/out */
extern fn int    PQgetline(PGconn *conn, char *buffer, int length);
extern fn int    PQputline(PGconn *conn, char *string);
extern fn int    PQgetlineAsync(PGconn *conn, char *buffer, int bufsize);
extern fn int    PQputnbytes(PGconn *conn, char *buffer, int nbytes);
extern fn int    PQendcopy(PGconn *conn);

/* Set blocking/nonblocking connection to the backend */
extern fn int    PQsetnonblocking(PGconn *conn, int arg);
extern fn int    PQisnonblocking(PGconn *conn);
extern fn int    PQisthreadsafe();
extern fn PGPing PQping(char *conninfo);
extern fn PGPing PQpingParams(char *const *keywords,
                           char *const *values, int expand_dbname);

/* Force the write buffer to be written (or at least try) */
extern fn int    PQflush(PGconn *conn);

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
                      int nargs);

/* Accessor functions for PGresult objects */
extern fn PGExecStatusType PQresultStatus(PGresult *res);
extern fn char *PQresStatus(PGExecStatusType status);
extern fn char *PQresultErrorMessage(PGresult *res);
extern fn char *PQresultVerboseErrorMessage(PGresult *res,
                                         PGVerbosity verbosity,
                                         PGContextVisibility show_context);
extern fn char *PQresultErrorField(PGresult *res, int fieldcode);
extern fn int    PQntuples(PGresult *res);
extern fn int    PQnfields(PGresult *res);
extern fn int    PQbinaryTuples(PGresult *res);
extern fn char *PQfname(PGresult *res, int field_num);
extern fn int    PQfnumber(PGresult *res, const char *field_name);
extern fn Oid    PQftable(PGresult *res, int field_num);
extern fn int    PQftablecol(PGresult *res, int field_num);
extern fn int    PQfformat(PGresult *res, int field_num);
extern fn Oid    PQftype(PGresult *res, int field_num);
extern fn int    PQfsize(PGresult *res, int field_num);
extern fn int    PQfmod(PGresult *res, int field_num);
extern fn char *PQcmdStatus(PGresult *res);
extern fn char *PQoidStatus(PGresult *res);    /* old and ugly */
extern fn Oid    PQoidValue(PGresult *res);    /* new and improved */
extern fn char *PQcmdTuples(PGresult *res);
extern fn char *PQgetvalue(PGresult *res, int tup_num, int field_num);
extern fn int    PQgetlength(PGresult *res, int tup_num, int field_num);
extern fn int    PQgetisnull(PGresult *res, int tup_num, int field_num);
extern fn int    PQnparams(PGresult *res);
extern fn Oid    PQparamtype(PGresult *res, int param_num);

/* Describe prepared statements and portals */
extern fn PGresult *PQdescribePrepared(PGconn *conn, char *stmt);
extern fn PGresult *PQdescribePortal(PGconn *conn, char *portal);
extern fn int    PQsendDescribePrepared(PGconn *conn, char *stmt);
extern fn int    PQsendDescribePortal(PGconn *conn, char *portal);

/* Delete a PGresult */
extern fn void PQclear(PGresult *res);

/* For freeing other alloc'd results, such as PGnotify structs */
extern fn void PQfreemem(void *ptr);

/* Exists for backward compatibility.  bjm 2003-03-24 */
macro PQfreeNotify(ptr) {
    return PQfreemem(ptr);
}

/* Error when no password was given. */
/* Note: depending on this is deprecated; use PQconnectionNeedsPassword(). */
const char *PQnoPasswordSupplied = "fe_sendauth: no password supplied\n";

/* Create and manipulate PGresults */
extern fn PGresult *PQmakeEmptyPGresult(PGconn *conn, PGExecStatusType status);
extern fn PGresult *PQcopyResult(PGresult *src, int flags);
extern fn int    PQsetResultAttrs(PGresult *res, int numAttributes, PGresAttDesc *attDescs);
extern fn void *PQresultAlloc(PGresult *res, size_t nBytes);
extern fn size_t PQresultMemorySize(PGresult *res);
extern fn int    PQsetvalue(PGresult *res, int tup_num, int field_num, char *value, int len);

/* Quoting strings before inclusion in queries. */
extern fn size_t PQescapeStringConn(PGconn *conn,
                                 char *to, char *from, size_t length,
                                 int *error);
extern fn char *PQescapeLiteral(PGconn *conn, char *str, size_t len);
extern fn char *PQescapeIdentifier(PGconn *conn, char *str, size_t len);
extern fn unsigned char *PQescapeByteaConn(PGconn *conn,
                                        unsigned char *from, size_t from_length,
                                        size_t *to_length);
extern fn unsigned char *PQunescapeBytea(unsigned char *strtext,
                                      size_t *retbuflen);

/* These forms are deprecated! */
extern fn size_t PQescapeString(char *to, char *from, size_t length);
extern fn unsigned char *PQescapeBytea(unsigned char *from, size_t from_length,
                                    size_t *to_length);



/* === in fe-print.c === */

extern fn void PQprint(FILE *fout, /* output stream */
                    PGresult *res,
                    PQprintOpt *po);    /* option structure */

/*
 * really old printing routines
 */
extern fn void PQdisplayTuples(PGresult *res,
                            FILE *fp,    /* where to send the output */
                            int fillAlign,    /* pad the fields with spaces */
                            char *fieldSep,    /* field separator */
                            int printHeader,    /* display headers? */
                            int quiet);

extern fn void PQprintTuples(PGresult *res,
                          FILE *fout,    /* output stream */
                          int PrintAttNames,    /* print attribute names */
                          int TerseOutput,    /* delimiter bars */
                          int colWidth);    /* width of column, if 0, use
                                             * variable width */


/* === in fe-lobj.c === */

/* Large-object access routines */
extern fn int    lo_open(PGconn *conn, Oid lobjId, int mode);
extern fn int    lo_close(PGconn *conn, int fd);
extern fn int    lo_read(PGconn *conn, int fd, char *buf, size_t len);
extern fn int    lo_write(PGconn *conn, int fd, char *buf, size_t len);
extern fn int    lo_lseek(PGconn *conn, int fd, int offset, int whence);
extern fn long lo_lseek64(PGconn *conn, int fd, long offset, int whence);
extern fn Oid    lo_creat(PGconn *conn, int mode);
extern fn Oid    lo_create(PGconn *conn, Oid lobjId);
extern fn int    lo_tell(PGconn *conn, int fd);
extern fn long lo_tell64(PGconn *conn, int fd);
extern fn int    lo_truncate(PGconn *conn, int fd, size_t len);
extern fn int    lo_truncate64(PGconn *conn, int fd, long len);
extern fn int    lo_unlink(PGconn *conn, Oid lobjId);
extern fn Oid    lo_import(PGconn *conn, char *filename);
extern fn Oid    lo_import_with_oid(PGconn *conn, char *filename, Oid lobjId);
extern fn int    lo_export(PGconn *conn, Oid lobjId, char *filename);

/* === in fe-misc.c === */

/* Get the version of the libpq library in use */
extern fn int    PQlibVersion();

/* Determine length of multibyte encoded char at *s */
extern fn int    PQmblen(char *s, int encoding);

/* Same, but not more than the distance to the end of string s */
extern fn int    PQmblenBounded(char *s, int encoding);

/* Determine display length of multibyte encoded char at *s */
extern fn int    PQdsplen(char *s, int encoding);

/* Get encoding id from environment variable PGCLIENTENCODING */
extern fn int    PQenv2encoding();

/* === in fe-auth.c === */

extern fn char *PQencryptPassword(char *passwd, const char *user);
extern fn char *PQencryptPasswordConn(PGconn *conn, char *passwd, const char *user, const char *algorithm);

/* === in encnames.c === */

extern fn int    pg_char_to_encoding(char *name);
extern fn char *pg_encoding_to_char(int encoding);
extern fn int    pg_valid_server_encoding_id(int encoding);

/* === in fe-secure-openssl.c === */

/* Support for overriding sslpassword handling with a callback */
def PQsslKeyPassHook_OpenSSL_type = fn int (char *buf, int size, PGconn *conn);
extern fn PQsslKeyPassHook_OpenSSL_type PQgetSSLKeyPassHook_OpenSSL();
extern fn void PQsetSSLKeyPassHook_OpenSSL(PQsslKeyPassHook_OpenSSL_type hook);
extern fn int    PQdefaultSSLKeyPassHook_OpenSSL(char *buf, int size, PGconn *conn);
