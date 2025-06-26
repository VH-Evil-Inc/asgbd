# -*- coding: utf-8 -*-
"""
Cassandra Driver for py-tpcc using cassandra-driver (CQL)
"""
import logging
import uuid
from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider
from cassandra.policies import DCAwareRoundRobinPolicy

class CassandraDriver:
    DEFAULT_CONFIG = {
        "hostname": ("The host address to the Cassandra database", "localhost"),
        "port": ("Port number", 9042),
        "name": ("Name", "tpcc"),
        "keyspace": ("Keyspace", "tpcc"),
        "replicationfactor": ("ReplicationFactor", 3),
        "username": ("Username", "cassandra"),
        "password": ("Password", "cassandra")
    }

    def __init__(self, ddl=None):
        self.config = {}
        self.cluster = None
        self.session = None

    def makeDefaultConfig(self):
        return self.DEFAULT_CONFIG

    def loadConfig(self, config):
        for key in self.DEFAULT_CONFIG.keys():
            assert key in config, f"Missing parameter '{key}' in configuration"
        self.config = config

    def connect(self):
        if self.session is not None:
            self.session.shutdown()
            self.cluster.shutdown()
        auth_provider = PlainTextAuthProvider(
            username=self.config["username"],
            password=self.config["password"]
        )
        self.cluster = Cluster(
            [self.config["hostname"]],
            port=int(self.config["port"]),
            auth_provider=auth_provider
        )
        self.session = self.cluster.connect()
        self.session.set_keyspace(self.config["keyspace"])

    def loadStart(self):
        self.connect()  # <-- This is the key line!
        logging.info("Starting data load...")

    def _create_schema(self):
        keyspace = self.config["keyspace"]
        replication = self.config["replicationfactor"]
        self.session.execute(f"""
            CREATE KEYSPACE IF NOT EXISTS {keyspace}
            WITH REPLICATION = {{
                'class': 'SimpleStrategy',
                'replication_factor': {replication}
            }};
        """)
        self.session.set_keyspace(keyspace)

        self.session.execute("""
            CREATE TABLE IF NOT EXISTS warehouse (
                w_id text,
                w_name text,
                w_street_1 text,
                w_street_2 text,
                w_city text,
                w_state text,
                w_zip text,
                w_tax text,
                w_ytd text,
                PRIMARY KEY (w_id)
            );
        """)
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS district (
                d_id text,
                d_w_id text,
                d_name text,
                d_street_1 text,
                d_street_2 text,
                d_city text,
                d_state text,
                d_zip text,
                d_tax text,
                d_ytd text,
                d_next_o_id text,
                PRIMARY KEY ((d_w_id, d_id))
            );
        """)
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS item (
                i_id text,
                i_im_id text,
                i_name text,
                i_price text,
                i_data text,
                PRIMARY KEY (i_id)
            );
        """)
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS customer (
                c_id text,
                c_d_id text,
                c_w_id text,
                c_first text,
                c_middle text,
                c_last text,
                c_street_1 text,
                c_street_2 text,
                c_city text,
                c_state text,
                c_zip text,
                c_phone text,
                c_since text,
                c_credit text,
                c_credit_lim text,
                c_discount text,
                c_balance text,
                c_ytd_payment text,
                c_payment_cnt text,
                c_delivery_cnt text,
                c_data text,
                PRIMARY KEY ((c_w_id, c_d_id, c_id))
            );
        """)
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS stock (
                s_i_id text,
                s_w_id text,
                s_quantity text,
                s_dist_01 text,
                s_dist_02 text,
                s_dist_03 text,
                s_dist_04 text,
                s_dist_05 text,
                s_dist_06 text,
                s_dist_07 text,
                s_dist_08 text,
                s_dist_09 text,
                s_dist_10 text,
                s_ytd text,
                s_order_cnt text,
                s_remote_cnt text,
                s_data text,
                PRIMARY KEY ((s_w_id, s_i_id))
            );
        """)
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS orders (
                o_id text,
                o_d_id text,
                o_w_id text,
                o_c_id text,
                o_entry_d text,
                o_carrier_id text,
                o_ol_cnt text,
                o_all_local text,
                PRIMARY KEY ((o_w_id, o_d_id, o_id))
            );
        """)
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS new_order (
                no_o_id text,
                no_d_id text,
                no_w_id text,
                PRIMARY KEY ((no_w_id, no_d_id, no_o_id))
            );
        """)
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS order_line (
                ol_o_id text,
                ol_d_id text,
                ol_w_id text,
                ol_number text,
                ol_i_id text,
                ol_supply_w_id text,
                ol_delivery_d text,
                ol_quantity text,
                ol_amount text,
                ol_dist_info text,
                PRIMARY KEY ((ol_w_id, ol_d_id, ol_o_id, ol_number))
            );
        """)
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS history (
                h_id uuid,
                h_c_id text,
                h_c_d_id text,
                h_c_w_id text,
                h_d_id text,
                h_w_id text,
                h_date text,
                h_amount text,
                h_data text,
                PRIMARY KEY (h_id)
            );
        """)

    def loadTuples(self, tableName, tuples):
        if not self.session:
            raise Exception("Cassandra session not initialized. Did you call connect()?")
        if len(tuples) == 0:
            return
        logging.debug(f"Loading into {tableName}")
        if tableName == 'ITEM':
            for row in tuples:
                i_id, i_im_id, i_name, i_price, i_data = [str(x) for x in row]
                self.session.execute(
                    "INSERT INTO item (i_id, i_im_id, i_name, i_price, i_data) VALUES (%s, %s, %s, %s, %s)",
                    (i_id, i_im_id, i_name, i_price, i_data)
                )
        elif tableName == 'WAREHOUSE':
            for row in tuples:
                w_id, w_name, w_street_1, w_street_2, w_city, w_state, w_zip, w_tax, w_ytd = [str(x) for x in row]
                self.session.execute(
                    "INSERT INTO warehouse (w_id, w_name, w_street_1, w_street_2, w_city, w_state, w_zip, w_tax, w_ytd) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (w_id, w_name, w_street_1, w_street_2, w_city, w_state, w_zip, w_tax, w_ytd)
                )
        elif tableName == 'CUSTOMER':
            for row in tuples:
                c_id, c_d_id, c_w_id, c_first, c_middle, c_last, c_street_1, c_street_2, c_city, c_state, c_zip, c_phone, c_since, c_credit, c_credit_lim, c_discount, c_balance, c_ytd_payment, c_payment_cnt, c_delivery_cnt, c_data = [str(x) for x in row]
                self.session.execute(
                    "INSERT INTO customer (c_id, c_d_id, c_w_id, c_first, c_middle, c_last, c_street_1, c_street_2, c_city, c_state, c_zip, c_phone, c_since, c_credit, c_credit_lim, c_discount, c_balance, c_ytd_payment, c_payment_cnt, c_delivery_cnt, c_data) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (c_id, c_d_id, c_w_id, c_first, c_middle, c_last, c_street_1, c_street_2, c_city, c_state, c_zip, c_phone, c_since, c_credit, c_credit_lim, c_discount, c_balance, c_ytd_payment, c_payment_cnt, c_delivery_cnt, c_data)
                )
        elif tableName == 'ORDERS':
            for row in tuples:
                o_id, o_d_id, o_w_id, o_c_id, o_entry_d, o_carrier_id, o_ol_cnt, o_all_local = [str(x) for x in row]
                self.session.execute(
                    "INSERT INTO orders (o_id, o_d_id, o_w_id, o_c_id, o_entry_d, o_carrier_id, o_ol_cnt, o_all_local) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
                    (o_id, o_d_id, o_w_id, o_c_id, o_entry_d, o_carrier_id, o_ol_cnt, o_all_local)
                )
        elif tableName == 'STOCK':
            for row in tuples:
                s_i_id, s_w_id, s_quantity, s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05, s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10, s_ytd, s_order_cnt, s_remote_cnt, s_data = [str(x) for x in row]
                self.session.execute(
                    "INSERT INTO stock (s_i_id, s_w_id, s_quantity, s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05, s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10, s_ytd, s_order_cnt, s_remote_cnt, s_data) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (s_i_id, s_w_id, s_quantity, s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05, s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10, s_ytd, s_order_cnt, s_remote_cnt, s_data)
                )
        elif tableName == 'DISTRICT':
            for row in tuples:
                d_id, d_w_id, d_name, d_street_1, d_street_2, d_city, d_state, d_zip, d_tax, d_ytd, d_next_o_id = [str(x) for x in row]
                self.session.execute(
                    "INSERT INTO district (d_id, d_w_id, d_name, d_street_1, d_street_2, d_city, d_state, d_zip, d_tax, d_ytd, d_next_o_id) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (d_id, d_w_id, d_name, d_street_1, d_street_2, d_city, d_state, d_zip, d_tax, d_ytd, d_next_o_id)
                )
        elif tableName == 'NEW_ORDER':
            for row in tuples:
                no_o_id, no_d_id, no_w_id = [str(x) for x in row]
                self.session.execute(
                    "INSERT INTO new_order (no_o_id, no_d_id, no_w_id) VALUES (%s, %s, %s)",
                    (no_o_id, no_d_id, no_w_id)
                )
        elif tableName == 'ORDER_LINE':
            for row in tuples:
                ol_o_id, ol_d_id, ol_w_id, ol_number, ol_i_id, ol_supply_w_id, ol_delivery_d, ol_quantity, ol_amount, ol_dist_info = [str(x) for x in row]
                self.session.execute(
                    "INSERT INTO order_line (ol_o_id, ol_d_id, ol_w_id, ol_number, ol_i_id, ol_supply_w_id, ol_delivery_d, ol_quantity, ol_amount, ol_dist_info) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (ol_o_id, ol_d_id, ol_w_id, ol_number, ol_i_id, ol_supply_w_id, ol_delivery_d, ol_quantity, ol_amount, ol_dist_info)
                )
        elif tableName == 'HISTORY':
            for row in tuples:
                h_c_id, h_c_d_id, h_c_w_id, h_d_id, h_w_id, h_date, h_amount, h_data = [str(x) for x in row]
                self.session.execute(
                    "INSERT INTO history (h_id, h_c_id, h_c_d_id, h_c_w_id, h_d_id, h_w_id, h_date, h_amount, h_data) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (uuid.uuid1(), h_c_id, h_c_d_id, h_c_w_id, h_d_id, h_w_id, h_date, h_amount, h_data)
                )
        else:
            logging.warning(f"Table {tableName} not implemented for loadTuples")

    def loadFinish(self):
        logging.info("Committing changes to database")

    def doDelivery(self, params):
        logging.debug("do delivery")
        w_id = str(params["w_id"])
        o_carrier_id = str(params["o_carrier_id"])
        ol_delivery_d = str(params["ol_delivery_d"])
        result = []
        for d_id in range(1, 10+1):  # DISTRICTS_PER_WAREHOUSE = 10
            d_id = str(d_id)
            # Get the oldest new_order for this warehouse and district
            rows = self.session.execute(
                "SELECT no_o_id FROM new_order WHERE no_w_id = %s AND no_d_id = %s LIMIT 1",
                (w_id, d_id)
            )
            if not rows.current_rows:
                continue
            no_o_id = rows.one()["no_o_id"]
            if int(no_o_id) <= -1:
                continue
            # Get the order
            order = self.session.execute(
                "SELECT o_c_id FROM orders WHERE o_w_id = %s AND o_d_id = %s AND o_id = %s",
                (w_id, d_id, no_o_id)
            ).one()
            if not order:
                continue
            c_id = str(order["o_c_id"])
            # Sum order_line amounts for this order
            rows = self.session.execute(
                "SELECT ol_amount FROM order_line WHERE ol_w_id = %s AND ol_d_id = %s AND ol_o_id = %s",
                (w_id, d_id, no_o_id)
            )
            ol_total = sum(float(row["ol_amount"]) for row in rows)
            # Update orders, order_line, customer, delete new_order
            self.session.execute(
                "UPDATE orders SET o_carrier_id = %s WHERE o_w_id = %s AND o_d_id = %s AND o_id = %s",
                (o_carrier_id, w_id, d_id, no_o_id)
            )
            self.session.execute(
                "UPDATE order_line SET ol_delivery_d = %s WHERE ol_w_id = %s AND ol_d_id = %s AND ol_o_id = %s",
                (ol_delivery_d, w_id, d_id, no_o_id)
            )
            self.session.execute(
                "DELETE FROM new_order WHERE no_w_id = %s AND no_d_id = %s AND no_o_id = %s",
                (w_id, d_id, no_o_id)
            )
            # Update customer balance
            customer = self.session.execute(
                "SELECT c_balance FROM customer WHERE c_w_id = %s AND c_d_id = %s AND c_id = %s",
                (w_id, d_id, c_id)
            ).one()
            if customer:
                new_balance = float(customer["c_balance"]) + ol_total
                self.session.execute(
                    "UPDATE customer SET c_balance = %s WHERE c_w_id = %s AND c_d_id = %s AND c_id = %s",
                    (str(new_balance), w_id, d_id, c_id)
                )
            result.append((d_id, no_o_id))
        return result

    def doNewOrder(self, params):
        logging.debug("do new order")
        w_id = str(params["w_id"])
        d_id = str(params["d_id"])
        c_id = str(params["c_id"])
        o_entry_d = str(params["o_entry_d"])
        i_ids = [str(i) for i in params["i_ids"]]
        i_w_ids = [str(i) for i in params["i_w_ids"]]
        i_qtys = [str(i) for i in params["i_qtys"]]
        all_local = all(i_w_id == w_id for i_w_id in i_w_ids)
        # Get warehouse tax rate
        w_tax = float(self.session.execute(
            "SELECT w_tax FROM warehouse WHERE w_id = %s",
            (w_id,)
        ).one()["w_tax"])
        # Get district info
        district = self.session.execute(
            "SELECT d_tax, d_next_o_id FROM district WHERE d_w_id = %s AND d_id = %s",
            (w_id, d_id)
        ).one()
        d_tax = float(district["d_tax"])
        d_next_o_id = str(district["d_next_o_id"])
        # Get customer info
        customer = self.session.execute(
            "SELECT c_discount, c_last, c_credit FROM customer WHERE c_w_id = %s AND c_d_id = %s AND c_id = %s",
            (w_id, d_id, c_id)
        ).one()
        c_discount = float(customer["c_discount"])
        # Update district next_o_id
        self.session.execute(
            "UPDATE district SET d_next_o_id = %s WHERE d_w_id = %s AND d_id = %s",
            (str(int(d_next_o_id) + 1), w_id, d_id)
        )
        # Insert order
        o_carrier_id = "-1"  # NULL_CARRIER_ID
        o_ol_cnt = str(len(i_ids))
        self.session.execute(
            "INSERT INTO orders (o_w_id, o_d_id, o_id, o_c_id, o_entry_d, o_carrier_id, o_ol_cnt, o_all_local) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
            (w_id, d_id, d_next_o_id, c_id, o_entry_d, o_carrier_id, o_ol_cnt, str(all_local))
        )
        # Insert new_order
        self.session.execute(
            "INSERT INTO new_order (no_w_id, no_d_id, no_o_id) VALUES (%s, %s, %s)",
            (w_id, d_id, d_next_o_id)
        )
        # Process each item
        total = 0.0
        item_data = []
        for i in range(len(i_ids)):
            ol_i_id = i_ids[i]
            ol_supply_w_id = i_w_ids[i]
            ol_quantity = i_qtys[i]
            # Get item info
            item = self.session.execute(
                "SELECT i_name, i_price, i_data FROM item WHERE i_id = %s",
                (ol_i_id,)
            ).one()
            if not item:
                return None
            i_name = item["i_name"]
            i_price = float(item["i_price"])
            i_data = item["i_data"]
            # Get stock info
            stock = self.session.execute(
                "SELECT s_quantity, s_ytd, s_order_cnt, s_remote_cnt, s_data FROM stock WHERE s_w_id = %s AND s_i_id = %s",
                (ol_supply_w_id, ol_i_id)
            ).one()
            if not stock:
                return None
            s_quantity = int(stock["s_quantity"])
            s_ytd = int(stock["s_ytd"])
            s_order_cnt = int(stock["s_order_cnt"])
            s_remote_cnt = int(stock["s_remote_cnt"])
            s_data = stock["s_data"]
            # Get s_dist_XX
            s_dist_col = f"s_dist_{int(d_id):02d}"
            s_dist_xx = stock[s_dist_col] if s_dist_col in stock else ""
            # Update stock
            s_ytd += int(ol_quantity)
            if s_quantity >= int(ol_quantity) + 10:
                s_quantity -= int(ol_quantity)
            else:
                s_quantity += 91 - int(ol_quantity)
            s_order_cnt += 1
            if ol_supply_w_id != w_id:
                s_remote_cnt += 1
            self.session.execute(
                f"UPDATE stock SET s_quantity = %s, s_ytd = %s, s_order_cnt = %s, s_remote_cnt = %s WHERE s_w_id = %s AND s_i_id = %s",
                (str(s_quantity), str(s_ytd), str(s_order_cnt), str(s_remote_cnt), ol_supply_w_id, ol_i_id)
            )
            # Determine brand_generic
            brand_generic = 'B' if (i_data.find("ORIGINAL") != -1 and s_data.find("ORIGINAL") != -1) else 'G'
            ol_amount = float(ol_quantity) * i_price
            total += ol_amount
            # Insert order_line
            ol_number = str(i+1)
            self.session.execute(
                "INSERT INTO order_line (ol_w_id, ol_d_id, ol_o_id, ol_number, ol_i_id, ol_supply_w_id, ol_delivery_d, ol_quantity, ol_amount, ol_dist_info) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (w_id, d_id, d_next_o_id, ol_number, ol_i_id, ol_supply_w_id, o_entry_d, ol_quantity, str(ol_amount), s_dist_xx)
            )
            item_data.append((i_name, s_quantity, brand_generic, i_price, ol_amount))
        total = total * (1 - c_discount) * (1 + w_tax + d_tax)
        misc = [(w_tax, d_tax, d_next_o_id, total)]
        return [customer, misc, item_data]

    def doPayment(self, params):
        logging.debug("do payment")
        w_id = str(params["w_id"])
        d_id = str(params["d_id"])
        h_amount = float(params["h_amount"])
        c_w_id = str(params["c_w_id"])
        c_d_id = str(params["c_d_id"])
        c_id = str(params["c_id"]) if params["c_id"] is not None else None
        c_last = str(params["c_last"]) if params["c_last"] is not None else None
        h_date = str(params["h_date"])
        if c_id is not None:
            # Get customer by ID
            customer = self.session.execute(
                "SELECT * FROM customer WHERE c_w_id = %s AND c_d_id = %s AND c_id = %s",
                (c_w_id, c_d_id, c_id)
            ).one()
            assert customer
            c_balance = float(customer["c_balance"]) - h_amount
            c_ytd_payment = float(customer["c_ytd_payment"]) + h_amount
            c_payment_cnt = int(customer["c_payment_cnt"]) + 1
            c_data = customer["c_data"]
            c_credit = customer["c_credit"]
        else:
            # Get customer by last name
            customers = list(self.session.execute(
                "SELECT * FROM customer WHERE c_w_id = %s AND c_d_id = %s AND c_last = %s ALLOW FILTERING",
                (c_w_id, c_d_id, c_last)
            ))
            assert customers
            idx = (len(customers) - 1) // 2
            customer = customers[idx]
            c_id = customer["c_id"]
            c_balance = float(customer["c_balance"]) - h_amount
            c_ytd_payment = float(customer["c_ytd_payment"]) + h_amount
            c_payment_cnt = int(customer["c_payment_cnt"]) + 1
            c_data = customer["c_data"]
            c_credit = customer["c_credit"]
        # Update warehouse and district
        warehouse = self.session.execute(
            "SELECT w_name, w_ytd FROM warehouse WHERE w_id = %s",
            (w_id,)
        ).one()
        district = self.session.execute(
            "SELECT d_name, d_ytd FROM district WHERE d_w_id = %s AND d_id = %s",
            (w_id, d_id)
        ).one()
        self.session.execute(
            "UPDATE warehouse SET w_ytd = %s WHERE w_id = %s",
            (str(float(warehouse["w_ytd"]) + h_amount), w_id)
        )
        self.session.execute(
            "UPDATE district SET d_ytd = %s WHERE d_w_id = %s AND d_id = %s",
            (str(float(district["d_ytd"]) + h_amount), w_id, d_id)
        )
        # Update customer
        if c_credit == "BC":
            new_data = f"{c_id} {c_d_id} {c_w_id} {d_id} {w_id} {h_amount}"
            new_data = (new_data + "|" + c_data)[:500]
            self.session.execute(
                "UPDATE customer SET c_balance = %s, c_ytd_payment = %s, c_payment_cnt = %s, c_data = %s WHERE c_w_id = %s AND c_d_id = %s AND c_id = %s",
                (str(c_balance), str(c_ytd_payment), str(c_payment_cnt), new_data, c_w_id, c_d_id, c_id)
            )
        else:
            self.session.execute(
                "UPDATE customer SET c_balance = %s, c_ytd_payment = %s, c_payment_cnt = %s WHERE c_w_id = %s AND c_d_id = %s AND c_id = %s",
                (str(c_balance), str(c_ytd_payment), str(c_payment_cnt), c_w_id, c_d_id, c_id)
            )
        # Insert history
        h_data = f"{warehouse['w_name']}    {district['d_name']}"
        self.session.execute(
            "INSERT INTO history (h_id, h_c_id, h_c_d_id, h_c_w_id, h_d_id, h_w_id, h_date, h_amount, h_data) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
            (uuid.uuid1(), c_id, c_d_id, c_w_id, d_id, w_id, h_date, str(h_amount), h_data)
        )
        return [warehouse, district, customer]

    def doOrderStatus(self, params):
        logging.debug("do order status")
        w_id = str(params["w_id"])
        d_id = str(params["d_id"])
        c_id = str(params["c_id"]) if params["c_id"] is not None else None
        c_last = str(params["c_last"]) if params["c_last"] is not None else None
        if c_id is None:
            # Get customer by last name
            customers = list(self.session.execute(
                "SELECT * FROM customer WHERE c_w_id = %s AND c_d_id = %s AND c_last = %s ALLOW FILTERING",
                (w_id, d_id, c_last)
            ))
            assert customers
            idx = (len(customers) - 1) // 2
            customer = customers[idx]
            c_id = customer["c_id"]
        else:
            customer = self.session.execute(
                "SELECT * FROM customer WHERE c_w_id = %s AND c_d_id = %s AND c_id = %s",
                (w_id, d_id, c_id)
            ).one()
        # Get last order for this customer
        orders = list(self.session.execute(
            "SELECT * FROM orders WHERE o_w_id = %s AND o_d_id = %s AND o_c_id = %s ORDER BY o_id DESC LIMIT 1",
            (w_id, d_id, c_id)
        ))
        order = orders[0] if orders else None
        # Get order lines for this order
        order_lines = []
        if order:
            order_lines = list(self.session.execute(
                "SELECT ol_supply_w_id, ol_i_id, ol_quantity, ol_amount, ol_delivery_d FROM order_line WHERE ol_w_id = %s AND ol_d_id = %s AND ol_o_id = %s",
                (w_id, d_id, order["o_id"])
            ))
        return [
            [customer["c_id"], customer["c_first"], customer["c_middle"], customer["c_last"], customer["c_balance"]],
            [order["o_id"], order["o_carrier_id"], order["o_entry_d"]] if order else None,
            [[ol["ol_supply_w_id"], ol["ol_i_id"], ol["ol_quantity"], ol["ol_amount"], ol["ol_delivery_d"]] for ol in order_lines]
        ]

    def doStockLevel(self, params):
        logging.debug("do stock level")
        w_id = str(params["w_id"])
        d_id = str(params["d_id"])
        threshold = int(params["threshold"])
        # Get next order id
        district = self.session.execute(
            "SELECT d_next_o_id FROM district WHERE d_w_id = %s AND d_id = %s",
            (w_id, d_id)
        ).one()
        o_id = district["d_next_o_id"]
        # Get item IDs from the last 20 order lines
        order_lines = list(self.session.execute(
            "SELECT ol_i_id FROM order_line WHERE ol_w_id = %s AND ol_d_id = %s AND ol_o_id < %s AND ol_o_id >= %s",
            (w_id, d_id, o_id, int(o_id)-20)
        ))
        item_ids = {ol["ol_i_id"] for ol in order_lines}
        # Count stocks below threshold
        count = 0
        for i_id in item_ids:
            stock = self.session.execute(
                "SELECT s_quantity FROM stock WHERE s_w_id = %s AND s_i_id = %s",
                (w_id, i_id)
            ).one()
            if stock and int(stock["s_quantity"]) < threshold:
                count += 1
        return count

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    driver = CassandraDriver()
    config = {
        "hostname": "cassandra",  # or "localhost" if not using Docker network
        "port": 9042,
        "keyspace": "tpcc",
        "replicationfactor": 3,
        "username": "cassandra",
        "password": "cassandra"
    }
    driver.loadConfig(config)
    driver.connect()
    print("Cassandra TPC-C driver ready.")
