-- sql
-- ============================================
-- MINI CORE BANKING SYSTEM — SQL PRACTICE DB
-- ============================================

CREATE DATABASE IF NOT EXISTS bank_practice;
USE bank_practice;

-- 1. BRANCHES
CREATE TABLE branches (
    branch_id       INT PRIMARY KEY AUTO_INCREMENT,
    branch_code     VARCHAR(10) UNIQUE NOT NULL,
    branch_name     VARCHAR(100) NOT NULL,
    county          VARCHAR(50),
    town            VARCHAR(50),
    opened_date     DATE,
    is_active       BOOLEAN DEFAULT TRUE
);

-- 2. CUSTOMERS
CREATE TABLE customers (
    customer_id     INT PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    phone           VARCHAR(20) UNIQUE,
    national_id     VARCHAR(20) UNIQUE,
    date_of_birth   DATE,
    gender          ENUM('M','F','O'),
    county          VARCHAR(50),
    occupation      VARCHAR(80),
    monthly_income  DECIMAL(12,2),
    kyc_status      ENUM('PENDING','VERIFIED','REJECTED') DEFAULT 'PENDING',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_customer_county (county),
    INDEX idx_customer_created (created_at)
);

-- 3. ACCOUNT TYPES
CREATE TABLE account_types (
    account_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name       VARCHAR(50) NOT NULL,  -- Savings, Current, Fixed Deposit
    min_balance     DECIMAL(12,2),
    interest_rate   DECIMAL(5,4),
    monthly_fee     DECIMAL(8,2)
);

-- 4. ACCOUNTS
CREATE TABLE accounts (
    account_id      INT PRIMARY KEY AUTO_INCREMENT,
    account_number  VARCHAR(20) UNIQUE NOT NULL,
    customer_id     INT NOT NULL,
    branch_id       INT NOT NULL,
    account_type_id INT NOT NULL,
    balance         DECIMAL(15,2) DEFAULT 0.00,
    currency        CHAR(3) DEFAULT 'KES',
    status          ENUM('ACTIVE','DORMANT','CLOSED','FROZEN') DEFAULT 'ACTIVE',
    opened_date     DATE,
    closed_date     DATE NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    FOREIGN KEY (account_type_id) REFERENCES account_types(account_type_id),
    INDEX idx_acc_customer (customer_id),
    INDEX idx_acc_status (status),
    INDEX idx_acc_opened (opened_date)
);

-- 5. TRANSACTIONS
CREATE TABLE transactions (
    transaction_id  BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_id      INT NOT NULL,
    txn_type        ENUM('DEPOSIT','WITHDRAWAL','TRANSFER_IN','TRANSFER_OUT','FEE','INTEREST'),
    amount          DECIMAL(15,2) NOT NULL,
    balance_after   DECIMAL(15,2),
    channel         ENUM('MOBILE','ATM','BRANCH','ONLINE','AGENT','POS'),
    reference       VARCHAR(50) UNIQUE,
    description     VARCHAR(200),
    txn_date        TIMESTAMP,
    status          ENUM('SUCCESS','FAILED','PENDING','REVERSED') DEFAULT 'SUCCESS',
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    INDEX idx_txn_account (account_id),
    INDEX idx_txn_date (txn_date),
    INDEX idx_txn_type (txn_type),
    INDEX idx_txn_channel (channel)
);

-- 6. LEDGER ENTRIES (double-entry)
CREATE TABLE ledger_entries (
    entry_id        BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_id  BIGINT NOT NULL,
    account_id      INT NOT NULL,
    debit           DECIMAL(15,2) DEFAULT 0.00,
    credit          DECIMAL(15,2) DEFAULT 0.00,
    entry_date      TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    INDEX idx_ledger_txn (transaction_id),
    INDEX idx_ledger_account (account_id)
);

-- 7. CARDS
CREATE TABLE cards (
    card_id         INT PRIMARY KEY AUTO_INCREMENT,
    account_id      INT NOT NULL,
    card_number     VARCHAR(20) UNIQUE,
    card_type       ENUM('DEBIT','CREDIT','PREPAID'),
    network         ENUM('VISA','MASTERCARD','AMEX'),
    expiry_date     DATE,
    status          ENUM('ACTIVE','BLOCKED','EXPIRED') DEFAULT 'ACTIVE',
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    INDEX idx_card_account (account_id)
);

-- 8. CARD TRANSACTIONS
CREATE TABLE card_transactions (
    card_txn_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
    card_id         INT NOT NULL,
    merchant_name   VARCHAR(100),
    merchant_category VARCHAR(50),
    amount          DECIMAL(15,2),
    txn_date        TIMESTAMP,
    location        VARCHAR(100),
    status          ENUM('APPROVED','DECLINED','REVERSED'),
    FOREIGN KEY (card_id) REFERENCES cards(card_id),
    INDEX idx_cardtxn_card (card_id),
    INDEX idx_cardtxn_date (txn_date)
);

-- 9. LOANS
CREATE TABLE loans (
    loan_id         INT PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT NOT NULL,
    account_id      INT NOT NULL,
    loan_type       ENUM('PERSONAL','MORTGAGE','AUTO','BUSINESS','EDUCATION'),
    principal       DECIMAL(15,2),
    interest_rate   DECIMAL(5,4),
    term_months     INT,
    disbursed_date  DATE,
    maturity_date   DATE,
    status          ENUM('ACTIVE','PAID','DEFAULTED','WRITTEN_OFF'),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    INDEX idx_loan_customer (customer_id),
    INDEX idx_loan_status (status)
);

-- 10. LOAN REPAYMENTS
CREATE TABLE loan_repayments (
    repayment_id    BIGINT PRIMARY KEY AUTO_INCREMENT,
    loan_id         INT NOT NULL,
    amount          DECIMAL(15,2),
    principal_part  DECIMAL(15,2),
    interest_part   DECIMAL(15,2),
    payment_date    DATE,
    status          ENUM('PAID','LATE','MISSED'),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id),
    INDEX idx_repay_loan (loan_id)
);

-- 11. BENEFICIARIES
CREATE TABLE beneficiaries (
    beneficiary_id  INT PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT NOT NULL,
    beneficiary_name VARCHAR(100),
    account_number  VARCHAR(20),
    bank_name       VARCHAR(100),
    nickname        VARCHAR(50),
    added_date      DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_benef_customer (customer_id)
);

-- 12. AUDIT LOG
CREATE TABLE audit_log (
    log_id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name      VARCHAR(50),
    record_id       BIGINT,
    action          ENUM('INSERT','UPDATE','DELETE'),
    changed_by      VARCHAR(50),
    change_time     TIMESTAMP,
    old_value       TEXT,
    new_value       TEXT,
    INDEX idx_audit_table (table_name),
    INDEX idx_audit_time (change_time)
);