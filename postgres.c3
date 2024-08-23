import libc;

def PG_Int64_Type = long;
def Oid = uint;

// #define InvalidOid		(Oid(0))

const uint OID_MAX = uint.max;

macro atooid(x) {
    return (Oid) strtoul((x), NULL, 10);
}

def PG_int64 = PG_Int64_Type;

const int PG_DIAG_SEVERITY = 'S';
const int PG_DIAG_SEVERITY_NONLOCALIZED = 'V';
const int PG_DIAG_SQLSTATE = 'C';
const int PG_DIAG_MESSAGE_PRIMARY = 'M';
const int PG_DIAG_MESSAGE_DETAIL = 'D';
const int PG_DIAG_MESSAGE_HINT = 'H';
const int PG_DIAG_STATEMENT_POSITION = 'P';
const int PG_DIAG_INTERNAL_POSITION = 'p';
const int PG_DIAG_INTERNAL_QUERY = 'q';
const int PG_DIAG_CONTEXT = 'W';
const int PG_DIAG_SCHEMA_NAME = 's';
const int PG_DIAG_TABLE_NAME = 't';
const int PG_DIAG_COLUMN_NAME = 'c';
const int PG_DIAG_DATATYPE_NAME = 'd';
const int PG_DIAG_CONSTRAINT_NAME = 'n';
const int PG_DIAG_SOURCE_FILE = 'F';
const int PG_DIAG_SOURCE_LINE = 'L';
const int PG_DIAG_SOURCE_FUNCTION = 'R';

const int LIBPQ_HAS_PIPELINING = 1;
const int LIBPQ_HAS_TRACE_FLAGS = 1;
const int LIBPQ_HAS_SSL_LIBRARY_DETECTION = 1;

const int PG_COPYRES_ATTRS = 0x01;
const int PG_COPYRES_TUPLES = 0x02;
const int PG_COPYRES_EVENTS = 0x04;
const int PG_COPYRES_NOTICEHOOKS = 0x08;

enum ConnStatusType {
	CONNECTION_OK,
	CONNECTION_BAD,
	/* Non-blocking mode only below here */

	/*
	 * The existence of these should never be relied upon - they should only
	 * be used for user feedback or similar purposes.
	 */
	CONNECTION_STARTED,			/* Waiting for connection to be made.  */
	CONNECTION_MADE,			/* Connection OK; waiting to send.     */
	CONNECTION_AWAITING_RESPONSE,	/* Waiting for a response from the
									 * postmaster.        */
	CONNECTION_AUTH_OK,			/* Received authentication; waiting for
								 * backend startup. */
	CONNECTION_SETENV,			/* This state is no longer used. */
	CONNECTION_SSL_STARTUP,		/* Negotiating SSL. */
	CONNECTION_NEEDED,			/* Internal state: connect() needed */
	CONNECTION_CHECK_WRITABLE,	/* Checking if session is read-write. */
	CONNECTION_CONSUME,			/* Consuming any extra messages. */
	CONNECTION_GSS_STARTUP,		/* Negotiating GSSAPI. */
	CONNECTION_CHECK_TARGET,	/* Checking target server properties. */
	CONNECTION_CHECK_STANDBY	/* Checking if server is in standby mode. */
}

enum PostgresPollingStatusType {
	PGRES_POLLING_FAILED,
	PGRES_POLLING_READING,		/* These two indicate that one may	  */
	PGRES_POLLING_WRITING,		/* use select before polling again.   */
	PGRES_POLLING_OK,
	PGRES_POLLING_ACTIVE		/* unused; keep for awhile for backwards
								 * compatibility */
}

enum ExecStatusType {
	PGRES_EMPTY_QUERY,		/* empty query string was executed */
	PGRES_COMMAND_OK,			/* a query command that doesn't return
								 * anything was executed properly by the
								 * backend */
	PGRES_TUPLES_OK,			/* a query command that returns tuples was
								 * executed properly by the backend, PGresult
								 * contains the result tuples */
	PGRES_COPY_OUT,				/* Copy Out data transfer in progress */
	PGRES_COPY_IN,				/* Copy In data transfer in progress */
	PGRES_BAD_RESPONSE,			/* an unexpected response was recv'd from the
								 * backend */
	PGRES_NONFATAL_ERROR,		/* notice or warning message */
	PGRES_FATAL_ERROR,			/* query failed */
	PGRES_COPY_BOTH,			/* Copy In/Out data transfer in progress */
	PGRES_SINGLE_TUPLE,			/* single tuple from larger resultset */
	PGRES_PIPELINE_SYNC,		/* pipeline synchronization point */
	PGRES_PIPELINE_ABORTED		/* Command didn't run because of an abort
								 * earlier in a pipeline */
}

enum PGTransactionStatusType {
	PQTRANS_IDLE,				/* connection idle */
	PQTRANS_ACTIVE,				/* command in progress */
	PQTRANS_INTRANS,			/* idle, within transaction block */
	PQTRANS_INERROR,			/* idle, within failed transaction */
	PQTRANS_UNKNOWN				/* cannot determine status */
}

enum PGVerbosity {
	PQERRORS_TERSE,				/* single-line error messages */
	PQERRORS_DEFAULT,			/* recommended style */
	PQERRORS_VERBOSE,			/* all the facts, ma'am */
	PQERRORS_SQLSTATE			/* only error severity and SQLSTATE code */
}

enum PGContextVisibility {
	PQSHOW_CONTEXT_NEVER,		/* never show CONTEXT field */
	PQSHOW_CONTEXT_ERRORS,		/* show CONTEXT for errors only (default) */
	PQSHOW_CONTEXT_ALWAYS		/* always show CONTEXT field */
}

/*
 * PGPing - The ordering of this enum should not be altered because the
 * values are exposed externally via pg_isready.
 */

enum PGPing {
	PQPING_OK,					/* server is accepting connections */
	PQPING_REJECT,				/* server is alive but rejecting connections */
	PQPING_NO_RESPONSE,			/* could not establish connection */
	PQPING_NO_ATTEMPT			/* connection not attempted (bad params) */
}

/*
 * PGpipelineStatus - Current status of pipeline mode
 */
enum PGpipelineStatus {
	PQ_PIPELINE_OFF,
	PQ_PIPELINE_ON,
	PQ_PIPELINE_ABORTED
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
 * Ideally this would be an opaque , but it's so simple that it's
 * unlikely to change.
 * NOTE: in Postgres 6.4 and later, the be_pid is the notifying backend's,
 * whereas in earlier versions it was always your own backend's PID.
 */
struct PGnotify {
	char	   *relname;		/* notification condition name */
	int			be_pid;			/* process ID of notifying server process */
	char	   *extra;			/* notification parameter */
	/* Fields below here are private to libpq; apps should not use 'em */
	PGnotify *next;		/* list link */
}

/* Function types for notice-handling callbacks */
def PQnoticeReceiver = fn void (void *arg, PGresult *res);
def PQnoticeProcessor = fn void (void *arg, char *message);

/* Print options for PQprint() */
def PQbool = char;

struct PQprintOpt {
	PQbool		header;			/* print output field headings and row count */
	PQbool		align;			/* fill align the fields */
	PQbool		standard;		/* old brain dead format */
	PQbool		html3;			/* output html tables */
	PQbool		expanded;		/* expand tables */
	PQbool		pager;			/* use pager for output if needed */
	char	   *fieldSep;		/* field separator */
	char	   *tableOpt;		/* insert to HTML <table ...> */
	char	   *caption;		/* HTML <caption> */
	char	  **fieldName;		/* null terminated array of replacement field
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
	char	   *keyword;		/* The keyword of the option			*/
	char	   *envvar;			/* Fallback environment variable name	*/
	char	   *compiled;		/* Fallback compiled in default value	*/
	char	   *val;			/* Option's current value, or NULL		 */
	char	   *label;			/* Label for field in connect dialog	*/
	char	   *dispchar;		/* Indicates how to display this field in a
								 * connect dialog. Values are: "" Display
								 * entered value as is "*" Password field -
								 * hide value "D"  Debug option - don't show
								 * by default */
	int			dispsize;		/* Field size in characters for dialog	*/
}

/* ----------------
 * PQArgBlock -- structure for PQfn() arguments
 * ----------------
 */
struct PQArgBlock {
	int			len;
	int			isint;
	union u
	{
		int		   *ptr;		/* can't use void (dec compiler barfs)	 */
		int			integer;
	}
}

/* ----------------
 * PGresAttDesc -- Data about a single attribute (column) of a query result
 * ----------------
 */
struct PQresAttDesc {
	char	   *name;			/* column name */
	Oid			tableid;		/* source table, if known */
	int			columnid;		/* source column, if known */
	int			format;			/* format code for value (text/binary) */
	Oid			typid;			/* type id */
	int			typlen;			/* type size */
	int			atttypmod;		/* type-specific modifier info */
}

/* ----------------
 * Exported functions of libpq
 * ----------------
 */

/* === in fe-connect.c === */

/* make a new client connection to the backend */
/* Asynchronous (non-blocking) */
extern fn PGconn *pq_connect_start(char *conninfo) @extern("PQconnectStart");
extern fn PGconn *pq_connect_start_params(char **keywords,
									char **values, int expand_dbname)
                                    @extern("PQconnectStartParams");
extern fn PostgresPollingStatusType pq_connect_poll(PGconn *conn) @extern("PQconnectPoll");

/* Synchronous (blocking) */
extern fn PGconn *pq_connect_db(char *conninfo) @extern("PQconnectdb");
extern fn PGconn *pq_connect_db_params(char **keywords,
								 char **values, int expand_dbname)
                                 @extern("PQconnectdbParams");
extern fn PGconn *pq_setdb_login(char *pghost, char *pgport,
							char *pgoptions, char *pgtty,
							char *dbName,
							char *login, char *pwd) @extern("PQsetdbLogin");

macro pq_setdb(m_pghost,m_pgport,m_pgopt,m_pgtty,m_dbname) {
	return pq_setdb_login(m_pghost, m_pgport, m_pgopt, m_pgtty, m_dbname, null,
    null);
}

/* close the current connection and free the PGconn data structure */
extern fn void pq_finish(PGconn *conn) @extern("PQfinish");

/* get info about connection options known to PQconnectdb */
extern fn PQconninfoOption *pq_conndefaults() @extern("PQconndefaults");

/* parse connection options in same way as PQconnectdb */
extern fn PQconninfoOption *pq_conninfo_parse(char *conninfo, char **errmsg)
@extern("PQconninfoParse");

/* return the connection options used by a live connection */
extern fn PQconninfoOption *pq_conninfo(PGconn *conn) @extern("PQconninfo");

/* free the data structure returned by PQconndefaults() or PQconninfoParse() */
extern fn void pq_conninfo_free(PQconninfoOption *connOptions) @extern("PQconninfoFree");

/*
 * close the current connection and reestablish a new one with the same
 * parameters
 */
/* Asynchronous (non-blocking) */
extern fn int pq_reset_start(PGconn *conn) @extern("PQresetStart");
extern fn PostgresPollingStatusType pq_reset_poll(PGconn *conn) @extern("PQresetPoll");

/* Synchronous (blocking) */
extern fn void pq_reset(PGconn *conn) @extern("PQreset");

/* request a cancel structure */
extern fn PGcancel *pq_getCancel(PGconn *conn) @extern("PQgetCancel");

/* free a cancel structure */
extern fn void pq_freeCancel(PGcancel *cancel) @extern("PQfreeCancel");

/* issue a cancel request */
extern fn int pq_cancel(PGcancel *cancel, char *errbuf, int errbufsize) @extern("PQcancel");

/* backwards compatible version of pq_cancel; not thread-safe */
extern fn int pq_requestCancel(PGconn *conn) @extern("PQrequestCancel");

/* Accessor functions for PGconn objects */
extern fn char *pq_db(PGconn *conn) @extern("PQdb");
extern fn char *pq_user(PGconn *conn) @extern("PQuser");
extern fn char *pq_pass(PGconn *conn) @extern("PQpass");
extern fn char *pq_host(PGconn *conn) @extern("PQhost");
extern fn char *pq_hostaddr(PGconn *conn) @extern("PQhostaddr");
extern fn char *pq_port(PGconn *conn) @extern("PQport");
extern fn char *pq_tty(PGconn *conn) @extern("PQtty");
extern fn char *pq_options(PGconn *conn) @extern("PQoptions");
extern fn ConnStatusType pq_status(PGconn *conn) @extern("PQstatus");
extern fn PGTransactionStatusType pq_transactionStatus(PGconn *conn) @extern("PQtransactionStatus");
extern fn char *pq_parameterStatus(PGconn *conn, char *paramName) @extern("PQparameterStatus");
extern fn int	pq_protocolVersion(PGconn *conn) @extern("PQprotocolVersion");
extern fn int	pq_serverVersion(PGconn *conn) @extern("PQserverVersion");
extern fn char *pq_errorMessage(PGconn *conn) @extern("PQerrorMessage");
extern fn int	pq_socket(PGconn *conn) @extern("PQsocket");
extern fn int	pq_backendPID(PGconn *conn) @extern("PQbackendPID");
extern fn PGpipelineStatus pq_pipelineStatus(PGconn *conn) @extern("PQpipelineStatus");
extern fn int	pq_connectionNeedsPassword(PGconn *conn) @extern("PQconnectionNeedsPassword");
extern fn int	pq_connectionUsedPassword(PGconn *conn) @extern("PQconnectionUsedPassword");
extern fn int	pq_connectionUsedGSSAPI(PGconn *conn) @extern("PQconnectionUsedGSSAPI");
extern fn int	pq_clientEncoding(PGconn *conn) @extern("PQclientEncoding");
extern fn int	pq_setClientEncoding(PGconn *conn, char *encoding) @extern("PQsetClientEncoding");

/* SSL information functions */
extern fn int	pq_sslInUse(PGconn *conn) @extern("PQsslInUse");
extern fn void *pq_sslStruct(PGconn *conn, char *struct_name) @extern("PQsslStruct");
extern fn char *pq_sslAttribute(PGconn *conn, char *attribute_name) @extern("PQsslAttribute");
extern fn char *pq_sslAttributeNames(PGconn *conn) @extern("PQsslAttributeNames");

/* Get the OpenSSL structure associated with a connection. Returns NULL for
 * unencrypted connections or if any other TLS library is in use. */
extern fn void *pq_getssl(PGconn *conn) @extern("PQgetssl");

/* Tell libpq whether it needs to initialize OpenSSL */
extern fn void pq_initSSL(int do_init) @extern("PQinitSSL");

/* More detailed way to tell libpq whether it needs to initialize OpenSSL */
extern fn void pq_initOpenSSL(int do_ssl, int do_crypto) @extern("PQinitOpenSSL");

/* Return true if GSSAPI encryption is in use */
extern fn int	pq_gssEncInUse(PGconn *conn) @extern("PQgssEncInUse");

/* Returns GSSAPI context if GSSAPI is in use */
extern fn void *pq_getgssctx(PGconn *conn) @extern("PQgetgssctx");

/* Set verbosity for pq_errorMessage and pq_resultErrorMessage */
extern fn PGVerbosity pq_setErrorVerbosity(PGconn *conn, PGVerbosity verbosity) @extern("PQsetErrorVerbosity");

/* Set CONTEXT visibility for pq_errorMessage and pq_resultErrorMessage */
extern fn PGContextVisibility pq_setErrorContextVisibility(PGconn *conn, PGContextVisibility show_context) @extern("PQsetErrorContextVisibility");

/* Override default notice handling routines */
extern fn PQnoticeReceiver pq_setNoticeReceiver(PGconn *conn, PQnoticeReceiver proc, void *arg) @extern("PQsetNoticeReceiver");
extern fn PQnoticeProcessor pq_setNoticeProcessor(PGconn *conn, PQnoticeProcessor proc, void *arg) @extern("PQsetNoticeProcessor");

/*
 *	   Used to set callback that prevents concurrent access to
 *	   non-thread safe functions that libpq needs.
 *	   The default implementation uses a libpq internal mutex.
 *	   Only required for multithreaded apps that use kerberos
 *	   both within their app and for postgresql connections.
 */
def PGthreadlock_t = fn void (int acquire);

extern fn PGthreadlock_t pq_registerThreadLock(PGthreadlock_t newhandler) @extern("PQregisterThreadLock");

/* === in fe-trace.c === */
extern fn void pq_trace(PGconn *conn, File *debug_port) @extern("PQtrace");
extern fn void pq_untrace(PGconn *conn) @extern("PQuntrace");

/* flags controlling trace output: */
/* omit timestamps from each line */
const int PQTRACE_SUPPRESS_TIMESTAMPS = (1<<0);
/* redact portions of some messages, for testing frameworks */
const int PQTRACE_REGRESS_MODE = (1<<1);
extern fn void pq_setTraceFlags(PGconn *conn, int flags) @extern("PQsetTraceFlags");

/* === in fe-exec.c === */

/* Simple synchronous query */
extern fn PGresult *pq_exec(PGconn *conn, char *query) @extern("PQexec");
extern fn PGresult *pq_execParams(PGconn *conn, char *command, int nParams, Oid *paramTypes, char **paramValues, int *paramLengths, int *paramFormats, int resultFormat) @extern("PQexecParams");
extern fn PGresult *pq_prepare(PGconn *conn, char *stmtName, char *query, int nParams, Oid *paramTypes) @extern("PQprepare");
extern fn PGresult *pq_execPrepared(PGconn *conn, char *stmtName, int nParams, char **paramValues, int *paramLengths, int *paramFormats, int resultFormat) @extern("PQexecPrepared");

/* Interface for multiple-result or asynchronous queries */
const int PQ_QUERY_PARAM_MAX_LIMIT = 65535;

extern fn int	pq_sendQuery(PGconn *conn, char *query) @extern("PQsendQuery");
extern fn int	pq_sendQueryParams(PGconn *conn, char *command, int nParams, Oid *paramTypes, char **paramValues, int *paramLengths, int *paramFormats, int resultFormat) @extern("PQsendQueryParams");
extern fn int	pq_sendPrepare(PGconn *conn, char *stmtName, char *query, int nParams, Oid *paramTypes) @extern("PQsendPrepare");
extern fn int	pq_sendQueryPrepared(PGconn *conn, char *stmtName, int nParams, char **paramValues, int *paramLengths, int *paramFormats, int resultFormat) @extern("PQsendQueryPrepared");
extern fn int	pq_setSingleRowMode(PGconn *conn) @extern("PQsetSingleRowMode");
extern fn PGresult *pq_getResult(PGconn *conn) @extern("PQgetResult");

/* Routines for managing an asynchronous query */
extern fn int	pq_isBusy(PGconn *conn) @extern("PQisBusy");
extern fn int	pq_consumeInput(PGconn *conn) @extern("PQconsumeInput");

/* Routines for pipeline mode management */
extern fn int	pq_enterPipelineMode(PGconn *conn) @extern("PQenterPipelineMode");
extern fn int	pq_exitPipelineMode(PGconn *conn) @extern("PQexitPipelineMode");
extern fn int	pq_pipelineSync(PGconn *conn) @extern("PQpipelineSync");
extern fn int	pq_sendFlushRequest(PGconn *conn) @extern("PQsendFlushRequest");

/* LISTEN/NOTIFY support */
extern fn PGnotify *pq_notifies(PGconn *conn) @extern("PQnotifies");

/* Routines for copy in/out */
extern fn int	pq_putCopyData(PGconn *conn, char *buffer, int nbytes) @extern("PQputCopyData");
extern fn int	pq_putCopyEnd(PGconn *conn, char *errormsg) @extern("PQputCopyEnd");
extern fn int	pq_getCopyData(PGconn *conn, char **buffer, int async)
@extern("PQgetCopyData");

/* Deprecated routines for copy in/out */
extern fn int	pq_getline(PGconn *conn, char *buffer, int length) @extern("PQgetline");
extern fn int	pq_putline(PGconn *conn, char *string) @extern("PQputline");
extern fn int	pq_getlineAsync(PGconn *conn, char *buffer, int bufsize) @extern("PQgetlineAsync");
extern fn int	pq_putnbytes(PGconn *conn, char *buffer, int nbytes) @extern("PQputnbytes");
extern fn int	pq_endcopy(PGconn *conn) @extern("PQendcopy");

/* Set blocking/nonblocking connection to the backend */
extern fn int	pq_setnonblocking(PGconn *conn, int arg) @extern("PQsetnonblocking");
extern fn int	pq_isnonblocking(PGconn *conn) @extern("PQisnonblocking");
extern fn int	pq_isthreadsafe() @extern("PQisthreadsafe");
extern fn PGPing pq_ping(char *conninfo) @extern("PQping");
extern fn PGPing pq_pingParams(char **keywords, char **values, int expand_dbname) @extern("PQpingParams");

/* Force the write buffer to be written (or at least try) */
extern fn int	pq_flush(PGconn *conn) @extern("PQflush");

/*
 * "Fast path" interface --- not really recommended for application
 * use
 */
extern fn PGresult *pq_fn(PGconn *conn, int fnid, int *result_buf, int *result_len, int result_is_int, PQArgBlock *args, int nargs) @extern("PQfn");

/* Accessor functions for PGresult objects */
extern fn ExecStatusType pq_resultStatus(PGresult *res) @extern("PQresultStatus");
extern fn char *pq_resStatus(ExecStatusType status) @extern("PQresStatus");
extern fn char *pq_resultErrorMessage(PGresult *res) @extern("PQresultErrorMessage");
extern fn char *pq_resultVerboseErrorMessage(PGresult *res, PGVerbosity verbosity, PGContextVisibility show_context) @extern("PQresultVerboseErrorMessage");
extern fn char *pq_resultErrorField(PGresult *res, int fieldcode) @extern("PQresultErrorField");
extern fn int	pq_ntuples(PGresult *res) @extern("PQntuples");
extern fn int	pq_nfields(PGresult *res) @extern("PQnfields");
extern fn int	pq_binaryTuples(PGresult *res) @extern("PQbinaryTuples");
extern fn char *pq_fname(PGresult *res, int field_num) @extern("PQfname");
extern fn int	pq_fnumber(PGresult *res, char *field_name) @extern("PQfnumber");
extern fn Oid	pq_ftable(PGresult *res, int field_num) @extern("PQftable");
extern fn int	pq_ftablecol(PGresult *res, int field_num) @extern("PQftablecol");
extern fn int	pq_fformat(PGresult *res, int field_num) @extern("PQfformat");
extern fn Oid	pq_ftype(PGresult *res, int field_num) @extern("PQftype");
extern fn int	pq_fsize(PGresult *res, int field_num) @extern("PQfsize");
extern fn int	pq_fmod(PGresult *res, int field_num) @extern("PQfmod");
extern fn char *pq_cmdStatus(PGresult *res) @extern("PQcmdStatus");
extern fn char *pq_oidStatus(PGresult *res) @extern("PQoidStatus");
extern fn Oid	pq_oidValue(PGresult *res) @extern("PQoidValue");
extern fn char *pq_cmdTuples(PGresult *res) @extern("PQcmdTuples");
extern fn char *pq_getvalue(PGresult *res, int tup_num, int field_num) @extern("PQgetvalue");
extern fn int	pq_getlength(PGresult *res, int tup_num, int field_num) @extern("PQgetlength");
extern fn int	pq_getisnull(PGresult *res, int tup_num, int field_num) @extern("PQgetisnull");
extern fn int	pq_nparams(PGresult *res) @extern("PQnparams");
extern fn Oid	pq_paramtype(PGresult *res, int param_num) @extern("PQparamtype");

/* Describe prepared statements and portals */
extern fn PGresult *pq_describePrepared(PGconn *conn, char *stmt) @extern("PQdescribePrepared");
extern fn PGresult *pq_describePortal(PGconn *conn, char *portal) @extern("PQdescribePortal");
extern fn int	pq_sendDescribePrepared(PGconn *conn, char *stmt) @extern("PQsendDescribePrepared");
extern fn int	pq_sendDescribePortal(PGconn *conn, char *portal) @extern("PQsendDescribePortal");

/* Delete a PGresult */
extern fn void pq_clear(PGresult *res) @extern("PQclear");

/* For freeing other alloc'd results, such as PGnotify structs */
extern fn void pq_freemem(void *ptr) @extern("PQfreemem");

/* Exists for backward compatibility.  bjm 2003-03-24 */
macro pq_freeNotify(ptr) {
    return pq_freemem(ptr);
}

/* Error when no password was given. */
/* Note: depending on this is deprecated; use PQconnectionNeedsPassword(). */
const char * PQ_NO_PASSWORD_SUPPLIED =	"fe_sendauth: no password supplied\n";

/* Create and manipulate PGresults */
extern fn PGresult *pq_makeEmptyPGresult(PGconn *conn, ExecStatusType status) @extern("PQmakeEmptyPGresult");
extern fn PGresult *pq_copyResult(PGresult *src, int flags) @extern("PQcopyResult");
extern fn int	pq_setResultAttrs(PGresult *res, int numAttributes, PGresAttDesc *attDescs) @extern("PQsetResultAttrs");
extern fn void *pq_resultAlloc(PGresult *res, long nbytes) @extern("PQresultAlloc");
extern fn long pq_resultMemorySize(PGresult *res) @extern("PQresultMemorySize");
extern fn int	pq_setvalue(PGresult *res, int tup_num, int field_num, char *value, int len) @extern("PQsetvalue");

/* Quoting strings before inclusion in queries. */
extern fn long pq_escapeStringConn(PGconn *conn, char *to, char *from, long length, int *error) @extern("PQescapeStringConn");
extern fn char *pq_escapeLiteral(PGconn *conn, char *str, long len) @extern("PQescapeLiteral");
extern fn char *pq_escapeIdentifier(PGconn *conn, char *str, long len) @extern("PQescapeIdentifier");
extern fn uint *pq_escapeByteaConnchar (PGconn *conn, char *from, long from_length, long *to_length) @extern("char ");
extern fn uint *pq_unescapeByteachar (char *strtext, long *retbuflen) @extern("char ");

/* These forms are deprecated! */
extern fn long pq_escapeString(char *to, char *from, long length) @extern("PQescapeString");
extern fn uint *pq_escapeByteachar (char *from, long from_length, long *to_length) @extern("char ");



/* === in fe-print.c === */

extern fn void pq_print(File *fout, PGresult *res, PQprintOpt *po) @extern("PQprint");

/*
 * really old printing routines
 */
extern fn void pq_displayTuples(PGresult *res, File *fp,	/* where to send the output */ int fillAlign,	/* pad the fields with spaces */ char *fieldSep,	/* field separator */ int printHeader,	/* display headers? */ int quiet) @extern("PQdisplayTuples");

extern fn void pq_printTuples(PGresult *res, File *fout,	/* output stream */
int print_att_names,	/* print attribute names */ int terse_output,	/* delimiter bars */ int colWidth) @extern("PQprintTuples");


/* === in fe-lobj.c === */

/* Large-object access routines */
extern fn int	lo_open(PGconn *conn, Oid lobjId, int mode) @extern("lo_open");
extern fn int	lo_close(PGconn *conn, int fd) @extern("lo_close");
extern fn int	lo_read(PGconn *conn, int fd, char *buf, long len) @extern("lo_read");
extern fn int	lo_write(PGconn *conn, int fd, char *buf, long len) @extern("lo_write");
extern fn int	lo_lseek(PGconn *conn, int fd, int offset, int whence) @extern("lo_lseek");
extern fn PG_int64 lo_lseek64(PGconn *conn, int fd, PG_int64 offset, int whence) @extern("lo_lseek64");
extern fn Oid	lo_creat(PGconn *conn, int mode) @extern("lo_creat");
extern fn Oid	lo_create(PGconn *conn, Oid lobjId) @extern("lo_create");
extern fn int	lo_tell(PGconn *conn, int fd) @extern("lo_tell");
extern fn PG_int64 lo_tell64(PGconn *conn, int fd) @extern("lo_tell64");
extern fn int	lo_truncate(PGconn *conn, int fd, long len) @extern("lo_truncate");
extern fn int	lo_truncate64(PGconn *conn, int fd, PG_int64 len) @extern("lo_truncate64");
extern fn int	lo_unlink(PGconn *conn, Oid lobjId) @extern("lo_unlink");
extern fn Oid	lo_import(PGconn *conn, char *filename) @extern("lo_import");
extern fn Oid	lo_import_with_oid(PGconn *conn, char *filename, Oid lobjId) @extern("lo_import_with_oid");
extern fn int	lo_export(PGconn *conn, Oid lobjId, char *filename) @extern("lo_export");

/* === in fe-misc.c === */

/* Get the version of the libpq library in use */
extern fn int	pq_libVersion() @extern("PQlibVersion");

/* Determine length of multibyte encoded char at *s */
extern fn int	pq_mblen(char *s, int encoding) @extern("PQmblen");

/* Same, but not more than the distance to the end of string s */
extern fn int	pq_mblenBounded(char *s, int encoding) @extern("PQmblenBounded");

/* Determine display length of multibyte encoded char at *s */
extern fn int	pq_dsplen(char *s, int encoding) @extern("PQdsplen");

/* Get encoding id from environment variable PGCLIENTENCODING */
extern fn int	pq_env2encoding() @extern("PQenv2encoding");

/* === in fe-auth.c === */

extern fn char *pq_encryptPassword(char *passwd, char *user) @extern("PQencryptPassword");
extern fn char *pq_encryptPasswordConn(PGconn *conn, char *passwd, char *user, char *algorithm) @extern("PQencryptPasswordConn");

/* === in encnames.c === */

extern fn int	pg_char_to_encoding(char *name) @extern("pg_char_to_encoding");
extern fn char *pg_encoding_to_char(int encoding) @extern("pg_encoding_to_char");
extern fn int	pg_valid_server_encoding_id(int encoding) @extern("pg_valid_server_encoding_id");

/* === in fe-secure-openssl.c === */

/* Support for overriding sslpassword handling with a callback */
def PQsslKeyPassHook_OpenSSL_type = fn int (char *buf, int size, PGconn *conn);
extern fn PQsslKeyPassHook_OpenSSL_type pq_getSSLKeyPassHook_OpenSSL() @extern("PQgetSSLKeyPassHook_OpenSSL");
extern fn void pq_setSSLKeyPassHook_OpenSSL(PQsslKeyPassHook_OpenSSL_type hook) @extern("PQsetSSLKeyPassHook_OpenSSL");
extern fn int pq_defaultSSLKeyPassHook_OpenSSL(char *buf, int size, PGconn *conn) @extern("PQdefaultSSLKeyPassHook_OpenSSL");
