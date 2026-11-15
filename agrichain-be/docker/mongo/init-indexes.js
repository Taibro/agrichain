db = db.getSiblingDB('supermarket_mongo');

db.food_batches.createIndex({ "batch_code": 1 }, { unique: true });
db.food_batches.createIndex({ "category": 1, "status": 1 });
db.food_batches.createIndex({ "producer.code": 1, "created_at": -1 });
db.food_batches.createIndex({ "aquaculture_details.harvest_date": 1 });

db.blockchain_ledger.createIndex({ "batch_code": 1, "index": 1 }, { unique: true });
db.blockchain_ledger.createIndex({ "current_hash": 1 }, { unique: true });
db.blockchain_ledger.createIndex({ "event_type": 1, "timestamp": -1 });
db.blockchain_ledger.createIndex({ "timestamp": -1 });

db.producer_profiles.createIndex({ "code": 1 }, { unique: true });
db.certificates.createIndex({ "supplier_code": 1, "valid_until": 1 });
db.certificates.createIndex({ "r2_key": 1 }, { unique: true });

// TTL tự dọn consumer_reports quá 180 ngày
db.consumer_reports.createIndex({ "created_at": 1 }, { expireAfterSeconds: 15552000 });
