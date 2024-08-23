import postgres::pg;
import postgres::pq;
import std::io;
import libc;

fn int main(String [] args) {
    PGconn *conn = pq::pq_connectdb(
        " host=localhost"
        " user=lucas"
        " dbname=lucas"
    );

    if (pq::pq_status(conn) == PGConnStatusType.BAD) {
        io::printf("Connection to postgresdatabase failed: %s\n",
                   pq::pq_errorMessage(conn));
        return 1;
    }
    return 0;
}
