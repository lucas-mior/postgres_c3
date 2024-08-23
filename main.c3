import postgres::pg;
import postgres::pq;
import std::io;
import libc;

fn int main(String [] args) {
    PGconn *conn = pq::connectdb(
        " host=localhost"
        " user=lucas"
        " dbname=lucas"
    );

    if (pq::status(conn) == PGConnStatusType.BAD) {
        io::printf("Connection to postgresdatabase failed: %s\n",
                   pq::errorMessage(conn));
        return 1;
    }
    return 0;
}
