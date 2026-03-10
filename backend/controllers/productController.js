const db = require('../config/db');

exports.getProducts = (req, res) => {
  db.query('SELECT * FROM products ORDER BY id DESC', (err, results) => {
    if (err) return res.status(500).json({ message: 'Failed to fetch products', error: err });
    res.json(results);
  });
};

exports.addProduct = (req, res) => {
  const {
    product_code,
    product_name,
    product_type,
    quantity,
    cost_price,
    selling_price
  } = req.body;

  if (!product_code || !product_name || !product_type || quantity == null || cost_price == null || selling_price == null) {
    return res.status(400).json({ message: 'All product fields are required' });
  }

  db.query(
    'SELECT * FROM products WHERE product_name = ? AND product_type = ?',
    [product_name, product_type],
    (findErr, results) => {
      if (findErr) {
        return res.status(500).json({ message: 'Failed to check existing product', error: findErr });
      }

      if (results.length > 0) {
        return res.status(400).json({
          message: 'This product already exists. Use Restock Product instead.'
        });
      }

      db.query(
        `INSERT INTO products
        (product_code, product_name, product_type, quantity, cost_price, selling_price, status)
        VALUES (?, ?, ?, ?, ?, ?, 'Available')`,
        [product_code, product_name, product_type, quantity, cost_price, selling_price],
        (insertErr, result) => {
          if (insertErr) {
            return res.status(500).json({ message: 'Failed to add product', error: insertErr });
          }

          return res.status(201).json({
            message: 'New product added successfully',
            id: result.insertId
          });
        }
      );
    }
  );
};

exports.restockProduct = (req, res) => {
  const { id } = req.params;
  const { quantity, cost_price, selling_price } = req.body;

  if (!quantity || Number(quantity) <= 0) {
    return res.status(400).json({ message: 'Valid restock quantity is required' });
  }

  db.query('SELECT * FROM products WHERE id = ?', [id], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database error', error: err });
    if (results.length === 0) return res.status(404).json({ message: 'Product not found' });

    const product = results[0];
    const newQuantity = Number(product.quantity) + Number(quantity);
    const updatedCostPrice = cost_price ?? product.cost_price;
    const updatedSellingPrice = selling_price ?? product.selling_price;

    db.query(
      `UPDATE products
       SET quantity = ?, cost_price = ?, selling_price = ?, status = 'Available'
       WHERE id = ?`,
      [newQuantity, updatedCostPrice, updatedSellingPrice, id],
      (updateErr) => {
        if (updateErr) {
          return res.status(500).json({ message: 'Failed to restock product', error: updateErr });
        }

        res.json({ message: 'Product restocked successfully' });
      }
    );
  });
};

exports.markProductSold = (req, res) => {
  const { id } = req.params;
  const { quantity_sold } = req.body;

  if (!quantity_sold || Number(quantity_sold) <= 0) {
    return res.status(400).json({ message: 'Valid quantity_sold is required' });
  }

  db.query('SELECT * FROM products WHERE id = ?', [id], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database error', error: err });
    if (results.length === 0) return res.status(404).json({ message: 'Product not found' });

    const product = results[0];

    if (product.quantity < Number(quantity_sold)) {
      return res.status(400).json({ message: 'Not enough stock available' });
    }

    const totalAmount = Number(quantity_sold) * parseFloat(product.selling_price);
    const profit = Number(quantity_sold) * (parseFloat(product.selling_price) - parseFloat(product.cost_price));
    const newQuantity = product.quantity - Number(quantity_sold);
    const newStatus = newQuantity === 0 ? 'Sold' : 'Available';

    db.query(
      'UPDATE products SET quantity = ?, status = ? WHERE id = ?',
      [newQuantity, newStatus, id],
      (updateErr) => {
        if (updateErr) return res.status(500).json({ message: 'Failed to update product', error: updateErr });

        db.query(
          `INSERT INTO sales (product_id, quantity_sold, selling_price, total_amount, profit)
           VALUES (?, ?, ?, ?, ?)`,
          [id, quantity_sold, product.selling_price, totalAmount, profit],
          (saleErr) => {
            if (saleErr) return res.status(500).json({ message: 'Failed to record sale', error: saleErr });

            res.json({ message: 'Product marked as sold successfully' });
          }
        );
      }
    );
  });
}

exports.deleteProduct = (req, res) => {
  const { id } = req.params;

  db.query('SELECT * FROM products WHERE id = ?', [id], (findErr, productResults) => {
    if (findErr) {
      return res.status(500).json({ message: 'Failed to check product', error: findErr });
    }

    if (productResults.length === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }

    db.query('SELECT * FROM sales WHERE product_id = ?', [id], (salesErr, salesResults) => {
      if (salesErr) {
        return res.status(500).json({ message: 'Failed to check sales history', error: salesErr });
      }

      if (salesResults.length > 0) {
        return res.status(400).json({
          message: 'Cannot delete this product because it already has sales history.'
        });
      }

      db.query('DELETE FROM products WHERE id = ?', [id], (deleteErr) => {
        if (deleteErr) {
          return res.status(500).json({ message: 'Failed to delete product', error: deleteErr });
        }

        res.json({ message: 'Product deleted successfully' });
      });
    });
  });
};