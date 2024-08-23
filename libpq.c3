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
typedef void (*PQnoticeReceiver) (void *arg, const PGresult *res);
typedef void (*PQnoticeProcessor) (void *arg, const char *message);

/* Print options for PQprint() */
typedef char pqbool;

typedef struct _PQprintOpt
{
    pqbool        header;            /* print output field headings and row count */
    pqbool        align;            /* fill align the fields */
    pqbool        standard;        /* old brain dead format */
    pqbool        html3;            /* output html tables */
    pqbool        expanded;        /* expand tables */
    pqbool        pager;            /* use pager for output if needed */
    char       *fieldSep;        /* field separator */
    char       *tableOpt;        /* insert to HTML <table ...> */
    char       *caption;        /* HTML <caption> */
    char      **fieldName;        /* null terminated array of replacement field
                                 * names */
} PQprintOpt;

/* ----------------
 * Structure for the conninfo parameter definitions returned by PQconndefaults
 * or PQconninfoParse.
 *
 * All fields except "val" point at static strings which must not be altered.
 * "val" is either NULL or a malloc'd current-value string.  PQconninfoFree()
 * will release both the val strings and the PQconninfoOption array itself.
 * ----------------
 */
typedef struct _PQconninfoOption
{
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
} PQconninfoOption;

/* ----------------
 * PQArgBlock -- structure for PQfn() arguments
 * ----------------
 */
typedef struct
{
    int            len;
    int            isint;
    union
    {
        int           *ptr;        /* can't use void (dec compiler barfs)     */
        int            integer;
    }            u;
} PQArgBlock;

/* ----------------
 * PGresAttDesc -- Data about a single attribute (column) of a query result
 * ----------------
 */
typedef struct pgresAttDesc
{
    char       *name;            /* column name */
    Oid            tableid;        /* source table, if known */
    int            columnid;        /* source column, if known */
    int            format;            /* format code for value (text/binary) */
    Oid            typid;            /* type id */
    int            typlen;            /* type size */
    int            atttypmod;        /* type-specific modifier info */
} PGresAttDesc;

/* ----------------
 * Exported functions of libpq
 * ----------------
 */

/* === in fe-connect.c === */

/* make a new client connection to the backend */
/* Asynchronous (non-blocking) */
extern PGconn *PQconnectStart(const char *conninfo);
extern PGconn *PQconnectStartParams(const char *const *keywords,
                                    const char *const *values, int expand_dbname);
extern PostgresPollingStatusType PQconnectPoll(PGconn *conn);

/* Synchronous (blocking) */
extern PGconn *PQconnectdb(const char *conninfo);
extern PGconn *PQconnectdbParams(const char *const *keywords,
                                 const char *const *values, int expand_dbname);
extern PGconn *PQsetdbLogin(const char *pghost, const char *pgport,
                            const char *pgoptions, const char *pgtty,
                            const char *dbName,
                            const char *login, const char *pwd);

#define PQsetdb(M_PGHOST,M_PGPORT,M_PGOPT,M_PGTTY,M_DBNAME)  \
    PQsetdbLogin(M_PGHOST, M_PGPORT, M_PGOPT, M_PGTTY, M_DBNAME, NULL, NULL)

/* close the current connection and free the PGconn data structure */
extern void PQfinish(PGconn *conn);

/* get info about connection options known to PQconnectdb */
extern PQconninfoOption *PQconndefaults(void);

/* parse connection options in same way as PQconnectdb */
extern PQconninfoOption *PQconninfoParse(const char *conninfo, char **errmsg);

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
extern char *PQdb(const PGconn *conn);
extern char *PQuser(const PGconn *conn);
extern char *PQpass(const PGconn *conn);
extern char *PQhost(const PGconn *conn);
extern char *PQhostaddr(const PGconn *conn);
extern char *PQport(const PGconn *conn);
extern char *PQtty(const PGconn *conn);
extern char *PQoptions(const PGconn *conn);
extern PGConnStatusType PQstatus(const PGconn *conn);
extern PGTransactionStatusType PQtransactionStatus(const PGconn *conn);
extern const char *PQparameterStatus(const PGconn *conn,
                                     const char *paramName);
extern int    PQprotocolVersion(const PGconn *conn);
extern int    PQserverVersion(const PGconn *conn);
extern char *PQerrorMessage(const PGconn *conn);
extern int    PQsocket(const PGconn *conn);
extern int    PQbackendPID(const PGconn *conn);
extern PGpipelineStatus PQpipelineStatus(const PGconn *conn);
extern int    PQconnectionNeedsPassword(const PGconn *conn);
extern int    PQconnectionUsedPassword(const PGconn *conn);
extern int    PQconnectionUsedGSSAPI(const PGconn *conn);
extern int    PQclientEncoding(const PGconn *conn);
extern int    PQsetClientEncoding(PGconn *conn, const char *encoding);

/* SSL information functions */
extern int    PQsslInUse(PGconn *conn);
extern void *PQsslStruct(PGconn *conn, const char *struct_name);
extern const char *PQsslAttribute(PGconn *conn, const char *attribute_name);
extern const char *const *PQsslAttributeNames(PGconn *conn);

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
typedef void (*pgthreadlock_t) (int acquire);

extern pgthreadlock_t PQregisterThreadLock(pgthreadlock_t newhandler);

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
extern PGresult *PQexec(PGconn *conn, const char *query);
extern PGresult *PQexecParams(PGconn *conn,
                              const char *command,
                              int nParams,
                              const Oid *paramTypes,
                              const char *const *paramValues,
                              const int *paramLengths,
                              const int *paramFormats,
                              int resultFormat);
extern PGresult *PQprepare(PGconn *conn, const char *stmtName,
                           const char *query, int nParams,
                           const Oid *paramTypes);
extern PGresult *PQexecPrepared(PGconn *conn,
                                const char *stmtName,
                                int nParams,
                                const char *const *paramValues,
                                const int *paramLengths,
                                const int *paramFormats,
                                int resultFormat);

/* Interface for multiple-result or asynchronous queries */
#define PQ_QUERY_PARAM_MAX_LIMIT 65535

extern int    PQsendQuery(PGconn *conn, const char *query);
extern int    PQsendQueryParams(PGconn *conn,
                              const char *command,
                              int nParams,
                              const Oid *paramTypes,
                              const char *const *paramValues,
                              const int *paramLengths,
                              const int *paramFormats,
                              int resultFormat);
extern int    PQsendPrepare(PGconn *conn, const char *stmtName,
                          const char *query, int nParams,
                          const Oid *paramTypes);
extern int    PQsendQueryPrepared(PGconn *conn,
                                const char *stmtName,
                                int nParams,
                                const char *const *paramValues,
                                const int *paramLengths,
                                const int *paramFormats,
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
extern int    PQputCopyData(PGconn *conn, const char *buffer, int nbytes);
extern int    PQputCopyEnd(PGconn *conn, const char *errormsg);
extern int    PQgetCopyData(PGconn *conn, char **buffer, int async);

/* Deprecated routines for copy in/out */
extern int    PQgetline(PGconn *conn, char *buffer, int length);
extern int    PQputline(PGconn *conn, const char *string);
extern int    PQgetlineAsync(PGconn *conn, char *buffer, int bufsize);
extern int    PQputnbytes(PGconn *conn, const char *buffer, int nbytes);
extern int    PQendcopy(PGconn *conn);

/* Set blocking/nonblocking connection to the backend */
extern int    PQsetnonblocking(PGconn *conn, int arg);
extern int    PQisnonblocking(const PGconn *conn);
extern int    PQisthreadsafe(void);
extern PGPing PQping(const char *conninfo);
extern PGPing PQpingParams(const char *const *keywords,
                           const char *const *values, int expand_dbname);

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
                      const PQArgBlock *args,
                      int nargs);

/* Accessor functions for PGresult objects */
extern PGExecStatusType PQresultStatus(const PGresult *res);
extern char *PQresStatus(PGExecStatusType status);
extern char *PQresultErrorMessage(const PGresult *res);
extern char *PQresultVerboseErrorMessage(const PGresult *res,
                                         PGVerbosity verbosity,
                                         PGContextVisibility show_context);
extern char *PQresultErrorField(const PGresult *res, int fieldcode);
extern int    PQntuples(const PGresult *res);
extern int    PQnfields(const PGresult *res);
extern int    PQbinaryTuples(const PGresult *res);
extern char *PQfname(const PGresult *res, int field_num);
extern int    PQfnumber(const PGresult *res, const char *field_name);
extern Oid    PQftable(const PGresult *res, int field_num);
extern int    PQftablecol(const PGresult *res, int field_num);
extern int    PQfformat(const PGresult *res, int field_num);
extern Oid    PQftype(const PGresult *res, int field_num);
extern int    PQfsize(const PGresult *res, int field_num);
extern int    PQfmod(const PGresult *res, int field_num);
extern char *PQcmdStatus(PGresult *res);
extern char *PQoidStatus(const PGresult *res);    /* old and ugly */
extern Oid    PQoidValue(const PGresult *res);    /* new and improved */
extern char *PQcmdTuples(PGresult *res);
extern char *PQgetvalue(const PGresult *res, int tup_num, int field_num);
extern int    PQgetlength(const PGresult *res, int tup_num, int field_num);
extern int    PQgetisnull(const PGresult *res, int tup_num, int field_num);
extern int    PQnparams(const PGresult *res);
extern Oid    PQparamtype(const PGresult *res, int param_num);

/* Describe prepared statements and portals */
extern PGresult *PQdescribePrepared(PGconn *conn, const char *stmt);
extern PGresult *PQdescribePortal(PGconn *conn, const char *portal);
extern int    PQsendDescribePrepared(PGconn *conn, const char *stmt);
extern int    PQsendDescribePortal(PGconn *conn, const char *portal);

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
extern PGresult *PQcopyResult(const PGresult *src, int flags);
extern int    PQsetResultAttrs(PGresult *res, int numAttributes, PGresAttDesc *attDescs);
extern void *PQresultAlloc(PGresult *res, size_t nBytes);
extern size_t PQresultMemorySize(const PGresult *res);
extern int    PQsetvalue(PGresult *res, int tup_num, int field_num, char *value, int len);

/* Quoting strings before inclusion in queries. */
extern size_t PQescapeStringConn(PGconn *conn,
                                 char *to, const char *from, size_t length,
                                 int *error);
extern char *PQescapeLiteral(PGconn *conn, const char *str, size_t len);
extern char *PQescapeIdentifier(PGconn *conn, const char *str, size_t len);
extern unsigned char *PQescapeByteaConn(PGconn *conn,
                                        const unsigned char *from, size_t from_length,
                                        size_t *to_length);
extern unsigned char *PQunescapeBytea(const unsigned char *strtext,
                                      size_t *retbuflen);

/* These forms are deprecated! */
extern size_t PQescapeString(char *to, const char *from, size_t length);
extern unsigned char *PQescapeBytea(const unsigned char *from, size_t from_length,
                                    size_t *to_length);



/* === in fe-print.c === */

extern void PQprint(FILE *fout, /* output stream */
                    const PGresult *res,
                    const PQprintOpt *po);    /* option structure */

/*
 * really old printing routines
 */
extern void PQdisplayTuples(const PGresult *res,
                            FILE *fp,    /* where to send the output */
                            int fillAlign,    /* pad the fields with spaces */
                            const char *fieldSep,    /* field separator */
                            int printHeader,    /* display headers? */
                            int quiet);

extern void PQprintTuples(const PGresult *res,
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
extern int    lo_write(PGconn *conn, int fd, const char *buf, size_t len);
extern int    lo_lseek(PGconn *conn, int fd, int offset, int whence);
extern long lo_lseek64(PGconn *conn, int fd, long offset, int whence);
extern Oid    lo_creat(PGconn *conn, int mode);
extern Oid    lo_create(PGconn *conn, Oid lobjId);
extern int    lo_tell(PGconn *conn, int fd);
extern long lo_tell64(PGconn *conn, int fd);
extern int    lo_truncate(PGconn *conn, int fd, size_t len);
extern int    lo_truncate64(PGconn *conn, int fd, long len);
extern int    lo_unlink(PGconn *conn, Oid lobjId);
extern Oid    lo_import(PGconn *conn, const char *filename);
extern Oid    lo_import_with_oid(PGconn *conn, const char *filename, Oid lobjId);
extern int    lo_export(PGconn *conn, Oid lobjId, const char *filename);

/* === in fe-misc.c === */

/* Get the version of the libpq library in use */
extern int    PQlibVersion(void);

/* Determine length of multibyte encoded char at *s */
extern int    PQmblen(const char *s, int encoding);

/* Same, but not more than the distance to the end of string s */
extern int    PQmblenBounded(const char *s, int encoding);

/* Determine display length of multibyte encoded char at *s */
extern int    PQdsplen(const char *s, int encoding);

/* Get encoding id from environment variable PGCLIENTENCODING */
extern int    PQenv2encoding(void);

/* === in fe-auth.c === */

extern char *PQencryptPassword(const char *passwd, const char *user);
extern char *PQencryptPasswordConn(PGconn *conn, const char *passwd, const char *user, const char *algorithm);

/* === in encnames.c === */

extern int    pg_char_to_encoding(const char *name);
extern const char *pg_encoding_to_char(int encoding);
extern int    pg_valid_server_encoding_id(int encoding);

/* === in fe-secure-openssl.c === */

/* Support for overriding sslpassword handling with a callback */
typedef int (*PQsslKeyPassHook_OpenSSL_type) (char *buf, int size, PGconn *conn);
extern PQsslKeyPassHook_OpenSSL_type PQgetSSLKeyPassHook_OpenSSL(void);
extern void PQsetSSLKeyPassHook_OpenSSL(PQsslKeyPassHook_OpenSSL_type hook);
extern int    PQdefaultSSLKeyPassHook_OpenSSL(char *buf, int size, PGconn *conn);
