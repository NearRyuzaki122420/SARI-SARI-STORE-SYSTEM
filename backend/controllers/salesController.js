const db = require('../config/db');

exports.getSales = (req, res) => {
  db.query(
    `SELECT sales.*, products.product_name, products.product_code, products.product_type
     FROM sales
     JOIN products ON sales.product_id = products.id
     ORDER BY sales.sold_at DESC`,
    (err, results) => {
      if (err) return res.status(500).json({ message: 'Failed to fetch sales', error: err });
      res.json(results);
    }
  );
};

exports.getProfitReport = (req, res) => {
  const { filter } = req.query;

  let query = '';

  if (filter === 'day') {
    query = `
      SELECT DATE(sold_at) AS label, SUM(total_amount) AS total_sales, SUM(profit) AS total_profit
      FROM sales
      GROUP BY DATE(sold_at)
      ORDER BY DATE(sold_at) DESC
    `;
  } else if (filter === 'week') {
    query = `
      SELECT CONCAT(YEAR(sold_at), '-W', WEEK(sold_at)) AS label, SUM(total_amount) AS total_sales, SUM(profit) AS total_profit
      FROM sales
      GROUP BY YEAR(sold_at), WEEK(sold_at)
      ORDER BY YEAR(sold_at) DESC, WEEK(sold_at) DESC
    `;
  } else if (filter === 'month') {
    query = `
      SELECT DATE_FORMAT(sold_at, '%Y-%m') AS label, SUM(total_amount) AS total_sales, SUM(profit) AS total_profit
      FROM sales
      GROUP BY DATE_FORMAT(sold_at, '%Y-%m')
      ORDER BY DATE_FORMAT(sold_at, '%Y-%m') DESC
    `;
  } else {
    return res.status(400).json({ message: 'Use filter=day, week, or month' });
  }

  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ message: 'Failed to fetch profit report', error: err });
    res.json(results);
  });
};