import postgres;
import std::io;
import libc;

fn int main(String [] args) {
    PGconn *conn = postgres::pq_connect_db(
        " host=localhost"
        " user=user"
        " dbname=user"
    );

    if (postgres::pq_status(conn) == CONNECTION_BAD) {
        io::printf("Connection to postgresdatabase failed: %s\n",
                   postgres::pq_errorMessage(conn));
        return 1;
    }
    return 0;
}
