import java.io.FileReader;
import java.sql.*;
import java.time.*;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

import javax.swing.JPasswordField;

public class BankDataGenerator {

    private static final String URL = "jdbc:mysql://localhost:3306/bank_practice";
    // + promptForDbName();
    private static final String USER = "root";
    private final static String PASS = promptForPassword();
    private static final Random RAND = new Random();
    private static final String[] COUNTIES = {
        "Nairobi","Mombasa","Kisumu","Nakuru","Eldoret","Thika","Nyeri",
        "Machakos","Meru","Kakamega","Garissa","Kitale","Malindi","Lamu"
    };
    private static final String[] FIRST_NAMES = {
        "Daniel","Antony","Brian","Kevin","John","Peter","James","Mary",
        "Grace","Faith","Mercy","Cynthia","Ann","Diana","Joseph","Samuel"
    };
    private static final String[] LAST_NAMES = {
        "Oyoo","Ochieng","Kamau","Mwangi","Otieno","Wanjiku","Achieng",
        "Mutua","Kipchoge","Cheruiyot","Njoroge","Odhiambo"
    };
    private static final String[] OCCUPATIONS = {
        "Teacher","Engineer","Doctor","Farmer","Trader","Driver","Nurse",
        "Developer","Accountant","Student","Business Owner","Civil Servant"
    };

    private final static String promptForPassword(){
       System.out.print("Enter your password :");
       Scanner scanner = new Scanner(System.in);
       //JPasswordField jPassword = new JPasswordField("Enter your password");
       final String password = scanner.nextLine().trim();
       //final String password = jPassword.getPassword().toString();
       scanner.close();
       return password;
    }

    

    public static void main(String[] args) throws SQLException {
        try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {
            conn.setAutoCommit(false);

            long start = System.currentTimeMillis();

            //generateBranches(conn, 100);//done
            //generateAccountTypes(conn);//done
            //generateCustomers(conn, 50_000);//done
            /*
            generateAccounts(conn, 200_000);
            
            generateTransactions(conn, 5_000_000);
            
            generateLedgerEntries(conn, 10_000_000);
            generateCards(conn, 150_000);
            generateCardTransactions(conn, 2_000_000);
            generateLoans(conn, 30_000);
            generateLoanRepayments(conn, 500_000);
            generateBeneficiaries(conn, 100_000);
            generateAuditLog(conn, 1_000_000);
            */

            conn.commit();
            long end = System.currentTimeMillis();
            System.out.println("Done in " + (end - start) / 1000 + " seconds");
        }
    }

    // ---------- GENERATORS ----------

    private static void generateBranches(Connection conn, int count) throws SQLException {
        String sql = "INSERT INTO branches (branch_code, branch_name, county, town, opened_date, is_active) VALUES (?,?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= count; i++) {
                String county = pick(COUNTIES);
                ps.setString(1, "BR" + String.format("%04d", i));
                ps.setString(2, county + " Branch " + i);
                ps.setString(3, county);
                ps.setString(4, county + " Town");
                ps.setDate(5, randomDate(2010, 2024));
                ps.setBoolean(6, RAND.nextDouble() > 0.1);
                ps.addBatch();
                if (i % 1000 == 0) ps.executeBatch();
            }
            ps.executeBatch();
        }
        System.out.println("Branches done");
    }

    private static void generateAccountTypes(Connection conn) throws SQLException {
        String sql = "INSERT INTO account_types (type_name, min_balance, interest_rate, monthly_fee) VALUES (?,?,?,?)";
        Object[][] types = {
            {"Savings", 1000.00, 0.0450, 0.00},
            {"Current", 5000.00, 0.0100, 500.00},
            {"Fixed Deposit", 50000.00, 0.0800, 0.00},
            {"Student", 0.00, 0.0300, 0.00},
            {"Joint", 2000.00, 0.0400, 200.00},
            {"Corporate", 100000.00, 0.0200, 2000.00},
            {"Diaspora", 10000.00, 0.0500, 300.00},
            {"Salary", 1000.00, 0.0350, 100.00},
            {"Junior", 500.00, 0.0400, 0.00},
            {"Premium", 250000.00, 0.0600, 5000.00}
        };
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Object[] t : types) {
                ps.setString(1, (String) t[0]);
                ps.setBigDecimal(2, new java.math.BigDecimal(t[1].toString()));
                ps.setBigDecimal(3, new java.math.BigDecimal(t[2].toString()));
                ps.setBigDecimal(4, new java.math.BigDecimal(t[3].toString()));
                ps.addBatch();
            }
            ps.executeBatch();
        }
        System.out.println("Account types done");
    }

    private static void generateCustomers(Connection conn, int count) throws SQLException {
        String sql = "INSERT INTO customers (first_name, last_name, email, phone, national_id, date_of_birth, gender, county, occupation, monthly_income, kyc_status, created_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= count; i++) {
                String first = pick(FIRST_NAMES);
                String last = pick(LAST_NAMES);
                ps.setString(1, first);
                ps.setString(2, last);
                ps.setString(3, first.toLowerCase() + "." + last.toLowerCase() + i + "@mail.com");
                ps.setString(4, "2547" + (
                    10000000 + i//RAND.nextInt(89999999)
                 )
                );
                ps.setString(5, String.valueOf(
                  //too long/shoeter collides//UUID.randomUUID().toString().subSequence(1,9)//avoid collisions on large data sets/could also make it sequential
                    20000000 + i //RAND.nextInt(9999999)+i+RAND.nextInt(i)
                    )
                );
                ps.setDate(6, randomDate(1960, 2005));
                ps.setString(7, pick(new String[]{"M","F","O"}));
                ps.setString(8, pick(COUNTIES));
                ps.setString(9, pick(OCCUPATIONS));
                ps.setBigDecimal(10, java.math.BigDecimal.valueOf(20000 + RAND.nextInt(480000)));
                ps.setString(11, pick(new String[]{"PENDING","VERIFIED","VERIFIED","VERIFIED","REJECTED"}));
                ps.setTimestamp(12, randomTimestamp(2020, 2026));
                ps.addBatch();
                if (i % 5000 == 0) ps.executeBatch();
            }
            ps.executeBatch();
        }
        System.out.println("Customers done");
    }

    private static void generateAccounts(Connection conn, int count) throws SQLException {
        String sql = "INSERT INTO accounts (account_number, customer_id, branch_id, account_type_id, balance, currency, status, opened_date) VALUES (?,?,?,?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= count; i++) {
                ps.setString(1, "01" + String.format("%010d", i));
                ps.setInt(2, 1 + RAND.nextInt(50_000));
                ps.setInt(3, 1 + RAND.nextInt(100));
                ps.setInt(4, 1 + RAND.nextInt(10));
                ps.setBigDecimal(5, java.math.BigDecimal.valueOf(RAND.nextDouble() * 500000));
                ps.setString(6, "KES");
                ps.setString(7, pick(new String[]{"ACTIVE","ACTIVE","ACTIVE","DORMANT","CLOSED","FROZEN"}));
                ps.setDate(8, randomDate(2015, 2026));
                ps.addBatch();
                if (i % 10000 == 0) ps.executeBatch();
            }
            ps.executeBatch();
        }
        System.out.println("Accounts done");
    }

    private static void generateTransactions(Connection conn, int count) throws SQLException {
        String sql = "INSERT INTO transactions (account_id, txn_type, amount, balance_after, channel, reference, description, txn_date, status) VALUES (?,?,?,?,?,?,?,?,?)";
        String[] types = {"DEPOSIT","WITHDRAWAL","TRANSFER_IN","TRANSFER_OUT","FEE","INTEREST"};
        String[] channels = {"MOBILE","ATM","BRANCH","ONLINE","AGENT","POS"};
        String[] statuses = {"SUCCESS","SUCCESS","SUCCESS","SUCCESS","FAILED","PENDING","REVERSED"};

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= count; i++) {
                ps.setInt(1, 1 + RAND.nextInt(200_000));
                ps.setString(2, pick(types));
                ps.setBigDecimal(3, java.math.BigDecimal.valueOf(10 + RAND.nextDouble() * 100000));
                ps.setBigDecimal(4, java.math.BigDecimal.valueOf(RAND.nextDouble() * 500000));
                ps.setString(5, pick(channels));
                ps.setString(6, "TXN" + System.nanoTime() + i);
                ps.setString(7, "Auto-generated transaction");
                ps.setTimestamp(8, randomTimestamp(2022, 2026));
                ps.setString(9, pick(statuses));
                ps.addBatch();
                if (i % 10000 == 0) {
                    ps.executeBatch();
                    System.out.println("  transactions: " + i);
                }
            }
            ps.executeBatch();
        }
        System.out.println("Transactions done");
    }

    //methods for ledger, cards, card_transactions, loans,
    //     repayments, beneficiaries, audit_log

    // ---------- HELPERS ----------

    private static String pick(String[] arr) {
        return arr[RAND.nextInt(arr.length)];
    }

    private static java.sql.Date randomDate(int startYear, int endYear) {
        LocalDate start = LocalDate.of(startYear, 1, 1);
        LocalDate end = LocalDate.of(endYear, 12, 31);
        long days = java.time.temporal.ChronoUnit.DAYS.between(start, end);
        return java.sql.Date.valueOf(start.plusDays(RAND.nextInt((int) days)));
    }

    private static Timestamp randomTimestamp(int startYear, int endYear) {
        LocalDateTime start = LocalDateTime.of(startYear, 1, 1, 0, 0);
        LocalDateTime end = LocalDateTime.of(endYear, 12, 31, 23, 59);
        long seconds = java.time.temporal.ChronoUnit.SECONDS.between(start, end);
        return Timestamp.valueOf(start.plusSeconds(RAND.nextLong(seconds)));
    }
}
