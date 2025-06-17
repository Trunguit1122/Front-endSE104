-- === SCHEMA: AUTHENTICATION ===
CREATE SCHEMA auth;

CREATE TABLE auth.ACCOUNT (
    account_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    account_role VARCHAR(20) NOT NULL CHECK (account_role IN ('admin', 'staff', 'agent')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE auth.USER (
    user_id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES auth.ACCOUNT(account_id) ON DELETE CASCADE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(15),
    address VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- === SCHEMA: AGENCY ===
CREATE SCHEMA agency;

CREATE TABLE agency.AgencyType (
    agency_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE NOT NULL,
    max_debt NUMERIC(15, 2) NOT NULL CHECK (max_debt >= 0),
    description TEXT
);

CREATE TABLE agency.District (
    district_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100),
    district_name VARCHAR(100) UNIQUE NOT NULL,
    max_agencies INTEGER NOT NULL CHECK (max_agencies > 0)
);

CREATE TABLE agency.AGENCY (
    agency_id SERIAL PRIMARY KEY,
    agency_name VARCHAR(150) NOT NULL,
    agency_type_id INTEGER NOT NULL REFERENCES agency.AgencyType(agency_type_id) ON DELETE RESTRICT,
    phone_number VARCHAR(15) NOT NULL,
    address VARCHAR(255) NOT NULL,
    district_id INTEGER NOT NULL REFERENCES agency.District(district_id) ON DELETE RESTRICT,
    email VARCHAR(100) UNIQUE,
    representative VARCHAR(100),
    reception_date DATE NOT NULL,
    debt_amount NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (debt_amount >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    user_id INTEGER UNIQUE REFERENCES auth.USER(user_id) ON DELETE SET NULL -- gắn agent với user
);

-- Mapping staff quản lý agency
CREATE TABLE agency.StaffAgency (
    staff_id INTEGER NOT NULL REFERENCES auth.USER(user_id) ON DELETE CASCADE,
    agency_id INTEGER NOT NULL REFERENCES agency.AGENCY(agency_id) ON DELETE CASCADE,
    PRIMARY KEY (staff_id, agency_id)
);

-- === SCHEMA: INVENTORY ===
CREATE SCHEMA INVENTORY;

CREATE TABLE INVENTORY.Unit (
    unit_id SERIAL PRIMARY KEY,
    unit_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE INVENTORY.Item (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(150) UNIQUE NOT NULL,
    unit_id INTEGER NOT NULL REFERENCES INVENTORY.Unit(unit_id) ON DELETE RESTRICT,
    price NUMERIC(15, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    description TEXT
);

CREATE TABLE INVENTORY.Receipt (
    receipt_id SERIAL PRIMARY KEY,
    receipt_date DATE NOT NULL DEFAULT CURRENT_DATE,
    user_id INTEGER NOT NULL REFERENCES auth.USER(user_id),
    agency_id INTEGER NOT NULL REFERENCES agency.AGENCY(agency_id),
    total_amount NUMERIC(18, 2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE INVENTORY.ReceiptDetail (
    receipt_detail_id SERIAL PRIMARY KEY,
    receipt_id INTEGER NOT NULL REFERENCES INVENTORY.Receipt(receipt_id),
    item_id INTEGER NOT NULL REFERENCES INVENTORY.Item(item_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(15, 2) NOT NULL CHECK (unit_price >= 0),
    line_total NUMERIC(18, 2) NOT NULL CHECK (line_total >= 0)
);
CREATE UNIQUE INDEX idx_receiptdetail_receipt_item ON INVENTORY.ReceiptDetail (receipt_id, item_id);

CREATE TABLE INVENTORY.Issue (
    issue_id SERIAL PRIMARY KEY,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    agency_id INTEGER NOT NULL REFERENCES agency.AGENCY(agency_id),
    user_id INTEGER NOT NULL REFERENCES auth.USER(user_id),
    total_amount NUMERIC(18, 2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE INVENTORY.IssueDetail (
    issue_detail_id SERIAL PRIMARY KEY,
    issue_id INTEGER NOT NULL REFERENCES INVENTORY.Issue(issue_id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES INVENTORY.Item(item_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(15, 2) NOT NULL CHECK (unit_price >= 0),
    line_total NUMERIC(18, 2) NOT NULL CHECK (line_total >= 0)
);
CREATE UNIQUE INDEX idx_issuedetail_issue_item ON INVENTORY.IssueDetail (issue_id, item_id);

-- === SCHEMA: FINANCE ===
CREATE SCHEMA FINANCE;

CREATE TABLE FINANCE.Payment (
    payment_id SERIAL PRIMARY KEY,
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    agency_id INTEGER NOT NULL REFERENCES agency.AGENCY(agency_id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES auth.USER(user_id) ON DELETE RESTRICT,
    amount_collected NUMERIC(15, 2) NOT NULL CHECK (amount_collected > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE FINANCE.Report (
    report_id SERIAL PRIMARY KEY,
    report_type VARCHAR(50) NOT NULL CHECK (report_type IN ('sales', 'debt')),
    report_date DATE NOT NULL DEFAULT CURRENT_DATE,
    data JSONB NOT NULL,
    created_by INTEGER NOT NULL REFERENCES auth.ACCOUNT(account_id) ON DELETE RESTRICT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE FINANCE.DebtTransaction (
    debt_id SERIAL PRIMARY KEY,
    agency_id INTEGER NOT NULL REFERENCES agency.AGENCY(agency_id) ON DELETE CASCADE,
    transaction_type VARCHAR(10) NOT NULL CHECK (transaction_type IN ('ISSUE', 'PAYMENT')),
    reference_id INTEGER,
    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(15,2) NOT NULL CHECK (amount >= 0),
    description TEXT
);

-- === SCHEMA: CONFIG ===
CREATE SCHEMA CONFIG;

CREATE TABLE CONFIG.Regulation (
    regulation_key VARCHAR(50) PRIMARY KEY,
    regulation_value VARCHAR(255) NOT NULL,
    description TEXT,
    last_updated_by INTEGER REFERENCES auth.USER(user_id) ON DELETE SET NULL,
    updated_at TIMESTAMP
);

-- === VIEW GỢI Ý ===
-- View báo cáo công nợ tổng hợp
CREATE VIEW FINANCE.v_debt_summary AS
SELECT 
    a.agency_id,
    a.agency_name,
    a.debt_amount,
    MAX(dt.transaction_date) AS last_transaction
FROM agency.AGENCY a
LEFT JOIN FINANCE.DebtTransaction dt ON a.agency_id = dt.agency_id
GROUP BY a.agency_id;

-- === TRIGGER ===
--1. Trigger kiểm tra nợ vượt giới hạn và cập nhật debt_amount
CREATE OR REPLACE FUNCTION update_debt_amount()
RETURNS TRIGGER AS $$
DECLARE
    v_max_debt NUMERIC(15, 2);
    v_current_debt NUMERIC(15, 2);
BEGIN
    SELECT at.max_debt, ag.debt_amount INTO v_max_debt, v_current_debt
    FROM agency.AGENCY ag
    JOIN agency.AgencyType at ON ag.agency_type_id = at.agency_type_id
    WHERE ag.agency_id = NEW.agency_id;

    IF NEW.transaction_type = 'ISSUE' THEN
        IF v_current_debt + NEW.amount > v_max_debt THEN
            RAISE EXCEPTION 'Vượt quá giới hạn nợ cho phép của đại lý!';
        END IF;

        UPDATE agency.AGENCY
        SET debt_amount = debt_amount + NEW.amount
        WHERE agency_id = NEW.agency_id;

    ELSIF NEW.transaction_type = 'PAYMENT' THEN
        UPDATE agency.AGENCY
        SET debt_amount = debt_amount - NEW.amount
        WHERE agency_id = NEW.agency_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_debt_amount ON finance.DebtTransaction;

CREATE TRIGGER trg_update_debt_amount
AFTER INSERT ON finance.DebtTransaction
FOR EACH ROW
EXECUTE FUNCTION update_debt_amount();


-- 2. Trigger cập nhật total_amount của Receipt
CREATE OR REPLACE FUNCTION update_receipt_total_amount()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE inventory.Receipt
    SET total_amount = (
        SELECT COALESCE(SUM(line_total), 0)
        FROM inventory.ReceiptDetail
        WHERE receipt_id = NEW.receipt_id
    )
    WHERE receipt_id = NEW.receipt_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_receipt_total ON inventory.ReceiptDetail;

CREATE TRIGGER trg_update_receipt_total
AFTER INSERT OR UPDATE OR DELETE ON inventory.ReceiptDetail
FOR EACH ROW
EXECUTE FUNCTION update_receipt_total_amount();


-- 3. Trigger cập nhật total_amount của Issue
CREATE OR REPLACE FUNCTION update_issue_total_amount()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE inventory.Issue
    SET total_amount = (
        SELECT COALESCE(SUM(line_total), 0)
        FROM inventory.IssueDetail
        WHERE issue_id = NEW.issue_id
    )
    WHERE issue_id = NEW.issue_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_issue_total ON inventory.IssueDetail;

CREATE TRIGGER trg_update_issue_total
AFTER INSERT OR UPDATE OR DELETE ON inventory.IssueDetail
FOR EACH ROW
EXECUTE FUNCTION update_issue_total_amount();


-- 4. Trigger giảm stock_quantity khi xuất kho
CREATE OR REPLACE FUNCTION reduce_stock_on_issue()
RETURNS TRIGGER AS $$
DECLARE
    v_current_stock INTEGER;
BEGIN
    SELECT stock_quantity INTO v_current_stock
    FROM inventory.Item
    WHERE item_id = NEW.item_id;

    IF v_current_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Không đủ hàng trong kho để xuất.';
    END IF;

    UPDATE inventory.Item
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE item_id = NEW.item_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_reduce_stock ON inventory.IssueDetail;

CREATE TRIGGER trg_reduce_stock
AFTER INSERT ON inventory.IssueDetail
FOR EACH ROW
EXECUTE FUNCTION reduce_stock_on_issue();


--6. Trigger tự động cập nhật updated_at cho mọi bảng có field đó (cập nhật thời gian chỉnh sửa)
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_updated_at_item ON inventory.Item;

CREATE TRIGGER trg_set_updated_at_item
BEFORE UPDATE ON inventory.Item
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

COMMIT;
