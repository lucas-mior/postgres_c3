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
extern PGconn *PQconnectStart(char *conninfo);
extern PGconn *PQconnectStartParams(char *const *keywords,
                                    char *const *values, int expand_dbname);
extern PostgresPollingStatusType PQconnectPoll(PGconn *conn);

/* Synchronous (blocking) */
extern PGconn *PQconnectdb(char *conninfo);
extern PGconn *PQconnectdbParams(char *const *keywords,
                                 char *const *values, int expand_dbname);
extern PGconn *PQsetdbLogin(char *pghost, const char *pgport,
                            char *pgoptions, const char *pgtty,
                            char *dbName,
                            char *login, const char *pwd);

#define PQsetdb(M_PGHOST,M_PGPORT,M_PGOPT,M_PGTTY,M_DBNAME)  \
    PQsetdbLogin(M_PGHOST, M_PGPORT, M_PGOPT, M_PGTTY, M_DBNAME, NULL, NULL)

/* close the current connection and free the PGconn data structure */
extern void PQfinish(PGconn *conn);

/* get info about connection options known to PQconnectdb */
extern PQconninfoOption *PQconndefaults();

/* parse connection options in same way as PQconnectdb */
extern PQconninfoOption *PQconninfoParse(char *conninfo, char **errmsg);

/* return the connection options used by a live connection */
extern PQconninfoOption *PQconninfo(PGconn *conn);

/* free the data structure returned by PQconndefaults() or PQconninfoParse() */
extern void PQconninfoFree(PQconninfoOption *connOptions);

/*
 * close the current connection and reestablish a new one with the same
 * parameters
 */
/* Asynchronous (non-blocking) */
extern int    PQresetStart(PGconn *conn);
extern PostgresPollingStatusType PQresetPoll(PGconn *conn);

/* Synchronous (blocking) */
extern void PQreset(PGconn *conn);

/* request a cancel structure */
extern PGcancel *PQgetCancel(PGconn *conn);

/* free a cancel structure */
extern void PQfreeCancel(PGcancel *cancel);

/* issue a cancel request */
extern int    PQcancel(PGcancel *cancel, char *errbuf, int errbufsize);

/* backwards compatible version of PQcancel; not thread-safe */
extern int    PQrequestCancel(PGconn *conn);

/* Accessor functions for PGconn objects */
extern char *PQdb(PGconn *conn);
extern char *PQuser(PGconn *conn);
extern char *PQpass(PGconn *conn);
extern char *PQhost(PGconn *conn);
extern char *PQhostaddr(PGconn *conn);
extern char *PQport(PGconn *conn);
extern char *PQtty(PGconn *conn);
extern char *PQoptions(PGconn *conn);
extern PGConnStatusType PQstatus(PGconn *conn);
extern PGTransactionStatusType PQtransactionStatus(PGconn *conn);
extern char *PQparameterStatus(const PGconn *conn,
                                     char *paramName);
extern int    PQprotocolVersion(PGconn *conn);
extern int    PQserverVersion(PGconn *conn);
extern char *PQerrorMessage(PGconn *conn);
extern int    PQsocket(PGconn *conn);
extern int    PQbackendPID(PGconn *conn);
extern PGpipelineStatus PQpipelineStatus(PGconn *conn);
extern int    PQconnectionNeedsPassword(PGconn *conn);
extern int    PQconnectionUsedPassword(PGconn *conn);
extern int    PQconnectionUsedGSSAPI(PGconn *conn);
extern int    PQclientEncoding(PGconn *conn);
extern int    PQsetClientEncoding(PGconn *conn, char *encoding);

/* SSL information functions */
extern int    PQsslInUse(PGconn *conn);
extern void *PQsslStruct(PGconn *conn, char *struct_name);
extern char *PQsslAttribute(PGconn *conn, const char *attribute_name);
extern char *const *PQsslAttributeNames(PGconn *conn);

/* Get the OpenSSL structure associated with a connection. Returns NULL for
 * unencrypted connections or if any other TLS library is in use. */
extern void *PQgetssl(PGconn *conn);

/* Tell libpq whether it needs to initialize OpenSSL */
extern void PQinitSSL(int do_init);

/* More detailed way to tell libpq whether it needs to initialize OpenSSL */
extern void PQinitOpenSSL(int do_ssl, int do_crypto);

/* Return true if GSSAPI encryption is in use */
extern int    PQgssEncInUse(PGconn *conn);

/* Returns GSSAPI context if GSSAPI is in use */
extern void *PQgetgssctx(PGconn *conn);

/* Set verbosity for PQerrorMessage and PQresultErrorMessage */
extern PGVerbosity PQsetErrorVerbosity(PGconn *conn, PGVerbosity verbosity);

/* Set CONTEXT visibility for PQerrorMessage and PQresultErrorMessage */
extern PGContextVisibility PQsetErrorContextVisibility(PGconn *conn,
                                                       PGContextVisibility show_context);

/* Override default notice handling routines */
extern PQnoticeReceiver PQsetNoticeReceiver(PGconn *conn,
                                            PQnoticeReceiver proc,
                                            void *arg);
extern PQnoticeProcessor PQsetNoticeProcessor(PGconn *conn,
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
extern void PQtrace(PGconn *conn, FILE *debug_port);
extern void PQuntrace(PGconn *conn);

/* flags controlling trace output: */
/* omit timestamps from each line */
#define PQTRACE_SUPPRESS_TIMESTAMPS        (1<<0)
/* redact portions of some messages, for testing frameworks */
#define PQTRACE_REGRESS_MODE            (1<<1)
extern void PQsetTraceFlags(PGconn *conn, int flags);

/* === in fe-exec.c === */

/* Simple synchronous query */
extern PGresult *PQexec(PGconn *conn, char *query);
extern PGresult *PQexecParams(PGconn *conn,
                              char *command,
                              int nParams,
                              Oid *paramTypes,
                              char *const *paramValues,
                              int *paramLengths,
                              int *paramFormats,
                              int resultFormat);
extern PGresult *PQprepare(PGconn *conn, char *stmtName,
                           char *query, int nParams,
                           Oid *paramTypes);
extern PGresult *PQexecPrepared(PGconn *conn,
                                char *stmtName,
                                int nParams,
                                char *const *paramValues,
                                int *paramLengths,
                                int *paramFormats,
                                int resultFormat);

/* Interface for multiple-result or asynchronous queries */
#define PQ_QUERY_PARAM_MAX_LIMIT 65535

extern int    PQsendQuery(PGconn *conn, char *query);
extern int    PQsendQueryParams(PGconn *conn,
                              char *command,
                              int nParams,
                              Oid *paramTypes,
                              char *const *paramValues,
                              int *paramLengths,
                              int *paramFormats,
                              int resultFormat);
extern int    PQsendPrepare(PGconn *conn, char *stmtName,
                          char *query, int nParams,
                          Oid *paramTypes);
extern int    PQsendQueryPrepared(PGconn *conn,
                                char *stmtName,
                                int nParams,
                                char *const *paramValues,
                                int *paramLengths,
                                int *paramFormats,
                                int resultFormat);
extern int    PQsetSingleRowMode(PGconn *conn);
extern PGresult *PQgetResult(PGconn *conn);

/* Routines for managing an asynchronous query */
extern int    PQisBusy(PGconn *conn);
extern int    PQconsumeInput(PGconn *conn);

/* Routines for pipeline mode management */
extern int    PQenterPipelineMode(PGconn *conn);
extern int    PQexitPipelineMode(PGconn *conn);
extern int    PQpipelineSync(PGconn *conn);
extern int    PQsendFlushRequest(PGconn *conn);

/* LISTEN/NOTIFY support */
extern PGnotify *PQnotifies(PGconn *conn);

/* Routines for copy in/out */
extern int    PQputCopyData(PGconn *conn, char *buffer, int nbytes);
extern int    PQputCopyEnd(PGconn *conn, char *errormsg);
extern int    PQgetCopyData(PGconn *conn, char **buffer, int async);

/* Deprecated routines for copy in/out */
extern int    PQgetline(PGconn *conn, char *buffer, int length);
extern int    PQputline(PGconn *conn, char *string);
extern int    PQgetlineAsync(PGconn *conn, char *buffer, int bufsize);
extern int    PQputnbytes(PGconn *conn, char *buffer, int nbytes);
extern int    PQendcopy(PGconn *conn);

/* Set blocking/nonblocking connection to the backend */
extern int    PQsetnonblocking(PGconn *conn, int arg);
extern int    PQisnonblocking(PGconn *conn);
extern int    PQisthreadsafe();
extern PGPing PQping(char *conninfo);
extern PGPing PQpingParams(char *const *keywords,
                           char *const *values, int expand_dbname);

/* Force the write buffer to be written (or at least try) */
extern int    PQflush(PGconn *conn);

/*
 * "Fast path" interface --- not really recommended for application
 * use
 */
extern PGresult *PQfn(PGconn *conn,
                      int fnid,
                      int *result_buf,
                      int *result_len,
                      int result_is_int,
                      PQArgBlock *args,
                      int nargs);

/* Accessor functions for PGresult objects */
extern PGExecStatusType PQresultStatus(PGresult *res);
extern char *PQresStatus(PGExecStatusType status);
extern char *PQresultErrorMessage(PGresult *res);
extern char *PQresultVerboseErrorMessage(PGresult *res,
                                         PGVerbosity verbosity,
                                         PGContextVisibility show_context);
extern char *PQresultErrorField(PGresult *res, int fieldcode);
extern int    PQntuples(PGresult *res);
extern int    PQnfields(PGresult *res);
extern int    PQbinaryTuples(PGresult *res);
extern char *PQfname(PGresult *res, int field_num);
extern int    PQfnumber(PGresult *res, const char *field_name);
extern Oid    PQftable(PGresult *res, int field_num);
extern int    PQftablecol(PGresult *res, int field_num);
extern int    PQfformat(PGresult *res, int field_num);
extern Oid    PQftype(PGresult *res, int field_num);
extern int    PQfsize(PGresult *res, int field_num);
extern int    PQfmod(PGresult *res, int field_num);
extern char *PQcmdStatus(PGresult *res);
extern char *PQoidStatus(PGresult *res);    /* old and ugly */
extern Oid    PQoidValue(PGresult *res);    /* new and improved */
extern char *PQcmdTuples(PGresult *res);
extern char *PQgetvalue(PGresult *res, int tup_num, int field_num);
extern int    PQgetlength(PGresult *res, int tup_num, int field_num);
extern int    PQgetisnull(PGresult *res, int tup_num, int field_num);
extern int    PQnparams(PGresult *res);
extern Oid    PQparamtype(PGresult *res, int param_num);

/* Describe prepared statements and portals */
extern PGresult *PQdescribePrepared(PGconn *conn, char *stmt);
extern PGresult *PQdescribePortal(PGconn *conn, char *portal);
extern int    PQsendDescribePrepared(PGconn *conn, char *stmt);
extern int    PQsendDescribePortal(PGconn *conn, char *portal);

/* Delete a PGresult */
extern void PQclear(PGresult *res);

/* For freeing other alloc'd results, such as PGnotify structs */
extern void PQfreemem(void *ptr);

/* Exists for backward compatibility.  bjm 2003-03-24 */
#define PQfreeNotify(ptr) PQfreemem(ptr)

/* Error when no password was given. */
/* Note: depending on this is deprecated; use PQconnectionNeedsPassword(). */
#define PQnoPasswordSupplied    "fe_sendauth: no password supplied\n"

/* Create and manipulate PGresults */
extern PGresult *PQmakeEmptyPGresult(PGconn *conn, PGExecStatusType status);
extern PGresult *PQcopyResult(PGresult *src, int flags);
extern int    PQsetResultAttrs(PGresult *res, int numAttributes, PGresAttDesc *attDescs);
extern void *PQresultAlloc(PGresult *res, size_t nBytes);
extern size_t PQresultMemorySize(PGresult *res);
extern int    PQsetvalue(PGresult *res, int tup_num, int field_num, char *value, int len);

/* Quoting strings before inclusion in queries. */
extern size_t PQescapeStringConn(PGconn *conn,
                                 char *to, char *from, size_t length,
                                 int *error);
extern char *PQescapeLiteral(PGconn *conn, char *str, size_t len);
extern char *PQescapeIdentifier(PGconn *conn, char *str, size_t len);
extern unsigned char *PQescapeByteaConn(PGconn *conn,
                                        unsigned char *from, size_t from_length,
                                        size_t *to_length);
extern unsigned char *PQunescapeBytea(unsigned char *strtext,
                                      size_t *retbuflen);

/* These forms are deprecated! */
extern size_t PQescapeString(char *to, char *from, size_t length);
extern unsigned char *PQescapeBytea(unsigned char *from, size_t from_length,
                                    size_t *to_length);



/* === in fe-print.c === */

extern void PQprint(FILE *fout, /* output stream */
                    PGresult *res,
                    PQprintOpt *po);    /* option structure */

/*
 * really old printing routines
 */
extern void PQdisplayTuples(PGresult *res,
                            FILE *fp,    /* where to send the output */
                            int fillAlign,    /* pad the fields with spaces */
                            char *fieldSep,    /* field separator */
                            int printHeader,    /* display headers? */
                            int quiet);

extern void PQprintTuples(PGresult *res,
                          FILE *fout,    /* output stream */
                          int PrintAttNames,    /* print attribute names */
                          int TerseOutput,    /* delimiter bars */
                          int colWidth);    /* width of column, if 0, use
                                             * variable width */


/* === in fe-lobj.c === */

/* Large-object access routines */
extern int    lo_open(PGconn *conn, Oid lobjId, int mode);
extern int    lo_close(PGconn *conn, int fd);
extern int    lo_read(PGconn *conn, int fd, char *buf, size_t len);
extern int    lo_write(PGconn *conn, int fd, char *buf, size_t len);
extern int    lo_lseek(PGconn *conn, int fd, int offset, int whence);
extern long lo_lseek64(PGconn *conn, int fd, long offset, int whence);
extern Oid    lo_creat(PGconn *conn, int mode);
extern Oid    lo_create(PGconn *conn, Oid lobjId);
extern int    lo_tell(PGconn *conn, int fd);
extern long lo_tell64(PGconn *conn, int fd);
extern int    lo_truncate(PGconn *conn, int fd, size_t len);
extern int    lo_truncate64(PGconn *conn, int fd, long len);
extern int    lo_unlink(PGconn *conn, Oid lobjId);
extern Oid    lo_import(PGconn *conn, char *filename);
extern Oid    lo_import_with_oid(PGconn *conn, char *filename, Oid lobjId);
extern int    lo_export(PGconn *conn, Oid lobjId, char *filename);

/* === in fe-misc.c === */

/* Get the version of the libpq library in use */
extern int    PQlibVersion();

/* Determine length of multibyte encoded char at *s */
extern int    PQmblen(char *s, int encoding);

/* Same, but not more than the distance to the end of string s */
extern int    PQmblenBounded(char *s, int encoding);

/* Determine display length of multibyte encoded char at *s */
extern int    PQdsplen(char *s, int encoding);

/* Get encoding id from environment variable PGCLIENTENCODING */
extern int    PQenv2encoding();

/* === in fe-auth.c === */

extern char *PQencryptPassword(char *passwd, const char *user);
extern char *PQencryptPasswordConn(PGconn *conn, char *passwd, const char *user, const char *algorithm);

/* === in encnames.c === */

extern int    pg_char_to_encoding(char *name);
extern char *pg_encoding_to_char(int encoding);
extern int    pg_valid_server_encoding_id(int encoding);

/* === in fe-secure-openssl.c === */

/* Support for overriding sslpassword handling with a callback */
def PQsslKeyPassHook_OpenSSL_type = fn int (char *buf, int size, PGconn *conn);
extern PQsslKeyPassHook_OpenSSL_type PQgetSSLKeyPassHook_OpenSSL();
extern void PQsetSSLKeyPassHook_OpenSSL(PQsslKeyPassHook_OpenSSL_type hook);
extern int    PQdefaultSSLKeyPassHook_OpenSSL(char *buf, int size, PGconn *conn);
