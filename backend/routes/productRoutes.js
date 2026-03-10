const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const {
  getProducts,
  addProduct,
  restockProduct,
  markProductSold,
  deleteProduct
} = require('../controllers/productController');

router.get('/', auth, getProducts);
router.post('/', auth, addProduct);
router.put('/restock/:id', auth, restockProduct);
router.put('/sold/:id', auth, markProductSold);
router.delete('/:id', auth, deleteProduct);

module.exports = router;