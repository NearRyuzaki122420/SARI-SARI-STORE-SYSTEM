const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const { getSales, getProfitReport } = require('../controllers/salesController');

router.get('/', auth, getSales);
router.get('/profit-report', auth, getProfitReport);

module.exports = router;