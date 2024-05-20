const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const crypto = require('crypto');

const cors=require('cors')
const app = express();
const port = 7700;

const pool = new Pool({
  user: 'shopuser',
  host: 'localhost',
  database: 'Curs',
  password: 'password',
  port: 5432, // or the port of your database server
});

app.use(express.json());
app.use(cors({
  origin: '*'
}));
app.use(bodyParser.json());
app.use(express.urlencoded({ extended: true }));

app.post('/login', async (req, res) => {
  const { login, password } = req.body;
  const passwordHash = crypto.createHash('sha256').update(password).digest('hex');
  const query = "SELECT * FROM users WHERE login = $1 AND password = $2";
  const values = [login, passwordHash];
 
  try {
     const client = await pool.connect();
     const result = await client.query(query, values);
     if (result.rowCount > 0) {
       const user = result.rows[0];
       res.status(200).json(user);
     } else {
       res.status(401).json({ message: 'Invalid login or password' });
     }
  } catch (error) {
     console.error(error);
     res.status(500).json({ message: 'Internal server error' });
  }
 });
 

//get-запрос на получение пунктов выдачи
app.get('/points', (req, res) => {
  pool.query('SELECT * FROM get_all_point_of_issue()', (err, dbRes) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Internal server error' });
    }
      console.log(dbRes.rows);
    res.json(dbRes.rows);
  });
});
app.post('/updateProfile', async (req, res) => {
  const { id, name, login, phonenumber, user_image, password } = req.body;
  try {
      // Создаем хеш пароля
      const passwordHash = crypto.createHash('sha256').update(password).digest('hex');

      const client = await pool.connect();
      const query = `
        UPDATE users
        SET name = $1, login = $2, phonenumber = $3, user_image = COALESCE($4, user_image), password = $5
        WHERE id = $6
        RETURNING *
      `;
      const values = [name, login, phonenumber, user_image, passwordHash, id];

      const result = await client.query(query, values);

      if (result.rowCount > 0) {
        res.status(200).json(result.rows[0]); // Возвращаем обновленные данные пользователя
      } else {
        res.status(404).json({ message: 'User not found' });
      }
  } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Internal server error' });
  } 
});

 


//гет-запрос на получение заказов
app.get('/showorders', async (req, res) => {
  const userId = req.params.userId;

  try {
    const query = `SELECT * FROM get_order_by_user_id($1)`;
    const values = [userId];
    const result = await pool.query(query, values);

    res.json(result.rows);
  } catch (error) {
    console.error('Error executing query', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

//создание пользователя (регистрация)
app.post('/users/create', async (req, res) => {
  const { name, password, phonenumber,login,role="customer" } = req.body;
  const passwordHash = crypto.createHash('sha256').update(password).digest('hex');
  try {
    const client = await pool.connect();
    const exists = await client.query(
      'SELECT 1 FROM users WHERE login = $1 OR phonenumber = $2',
      [login, phonenumber]
    );
    if (exists.rows.length > 0) {
      res.status(400).send('User with the same login or phone number already exists');
      return;
    }
    const result = await client.query(
      'INSERT INTO users (name, password, phonenumber,login,role) VALUES ($1, $2, $3, $4,$5) RETURNING *',
      [name, passwordHash, phonenumber,login,role]
    );
    client.release();
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Internal server error');
  }
});
app.post('/users/check', async (req, res) => {
  const { login, phonenumber } = req.body;
  console.log(req.body);
  try {
    const client = await pool.connect();
    const exists = await client.query(
      'SELECT EXISTS(SELECT 1 FROM users WHERE login = $1 OR phonenumber = $2)',
      [login, phonenumber]
    );
    client.release();
    res.json({ exists: exists.rows[0].exists });
  } catch (err) {
    console.error(err);
    res.status(500).send('Internal server error');
  }
});



app.post('/newItem', async (req, res) => {
  const { name, description, cost, count, category, image, raiting } = req.body;
  const client = await pool.connect();
  try {
    const result = await client.query(
      'SELECT add_item($1, $2, $3, $4, $5, $6, $7)', // Обновленный запрос с новым параметром
      [name, description, cost, count, category, image, raiting] // Добавлен raiting в список параметров
    );
    console.log(`New item added with name ${name}`);
    res.status(200).send(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).send('Internal server error');
  } finally {
    client.release();
  }
});



app.post('/delete', async (req, res) => {
  const itemId = req.body.itemId; // Используем itemId вместо item_name

  try {
    const query = {
      text: 'DELETE FROM items WHERE id = $1', // Измененный запрос для удаления по id
      values: [itemId],
    };
    console.log(`Item deleted with id ${itemId}`);

    await pool.query(query);

    res.status(200).json({ message: `Item ${itemId} deleted successfully.` });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error deleting item.' });
  }
});



app.get('/items', async (req, res) => {
  
  try {
    const { rows } = await pool.query('SELECT * FROM get_all_items()');
    console.log(rows);
    
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).send('Error fetching items');
  }
});
app.get('/api/purchase-stats', async (req, res) => {
  try {
    
    const result = await pool.query('SELECT * FROM total_purchases_by_time_period()');
    res.json(result.rows);
    
    console.log(result); // Corrected from Console.log to console.log
  } catch (error) {
    console.error(error);
    res.status(500).send('Error fetching purchase stats');
    return; // Ensure we exit the function after sending the response
  }
});



app.get('/order', (req, res) => {
  const userId = req.query.userId;
  pool.query(`SELECT * FROM get_order_by_user_id(${userId})`, (error, result) => {
    if (error) {
      console.error(error);
      res.status(500).send('Error fetching order id');
    } else {
      res.status(200).json(result.rows);
    }
  });
});


app.get('/order-items', (req, res) => {
  const orderId = req.query.orderId;
  pool.query(`SELECT * FROM get_order_items(${orderId})`, (error, result) => {
    if (error) {
      console.error(error);
      res.status(500).send('Error fetching order items');
    } else {
      res.status(200).json(result.rows);
    }
  });
});

app.post('/updateOrderStatus', async (req, res) => {
  const {order_id, order_status} = req.body
  const query = 'select update_order_status($1, $2)';
  const values = [order_id, order_status];
  try{
    await pool.query(query, values);
    console.log('status updated!');
    res.send('status updated');
  }
  catch(error){
    console.log(error);
    res.status(500).send('Error on updating order status');
  }
})

app.post('/getOrderDetails', async (req, res) => {
  const {order_id} = req.body;
  const query = 'select * from get_order_details($1)';
  const values = [order_id];
  try{
    const {rows} = await pool.query(query, values);
    console.log(rows);
    res.json(rows);
  }
  catch(error){
    console.log(error);
    res.status(500).send('Error on getting order detailds');
  }
})

app.post('/getUserOrders', async (req, res) => {
  const {user_id} = req.body;
  const query = 'select * from get_user_orders($1)';
  const values = [user_id];
  try {
    const { rows } = await pool.query(query, values);
    console.log(rows);
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).send('Error fetching user orders');
  }
})

app.post('/addOrderDetail', (req, res) => {
  const {item_id, order_id, count} = req.body;
  const query = 'select add_detail_to_order($1, $2, $3)';
  const values = [item_id, order_id, count];
  pool.query(query, values).then(
    (result) => {
      console.log(`Item ${item_id} successfully added`);
      res.status(200).send(`Item ${item_id} successfully added`);
    }
  ).catch(
    (error) => {
      console.log(error);
      res.status(500).write("error under adding order detail operation!");
    }
  )
})

app.post('/createOrder', (req,res) => {
  const {point_id, user_id} = req.body;
  const query = 'select create_order($1, $2)';
  const values = [point_id, user_id];
  pool.query(query, values).then(
    (result) => {
      res.status(200).json({
        order_id: result.rows
      })
    }
  ).catch(
    (error) => {
      console.log(error);
      res.status(500).write("error under creating order operation!");
    }
  )
  
});

//Коментарии
app.post('/addComment', async (req, res) => {
  const { userId, itemId, commentText } = req.body;
  console.log(req.body);

  try {
    const client = await pool.connect();
    const query = `
      INSERT INTO comment (id_user, id_items, description)
      VALUES ($2, $1, $3)
      RETURNING *;
    `;
    const values = [userId, itemId, commentText]; // Используем commentText напрямую

    const result = await client.query(query, values);

    if (result.rowCount > 0) {
      res.status(200).json(result.rows[0]); // Возвращаем добавленный комментарий
    } else {
      res.status(404).json({ message: 'Comment not added' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  } 
});

// Эндпоинт для получения комментариев по itemId
app.get('/getCommentsForItem/:itemId', async (req, res) => {
  const itemId = req.params.itemId;
 
  try {
     const client = await pool.connect();
     const query = `
       SELECT * FROM comment WHERE id_items = $1;
     `;
     const values = [itemId];
 
     const result = await client.query(query, values);
 
     if (result.rowCount > 0) {
       res.status(200).json(result.rows); // Возвращаем список комментариев
     } else {
       res.status(404).json({ message: 'No comments found for this item' });
     }
  } catch (error) {
     console.error(error);
     res.status(500).json({ message: 'Internal server error' });
  }
 });
 app.delete('/deleteComment/:idComment', async (req, res) => {
  const idComment = req.params.idComment;

  try {
    const client = await pool.connect();
    const query = `
      DELETE FROM comment WHERE id_comment = $1;
    `;
    const values = [idComment];

    const result = await client.query(query, values);

    if (result.rowCount > 0) {
      res.status(200).json({ message: 'Comment deleted successfully' });
    } else {
      res.status(404).json({ message: 'Comment not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});
app.get('/getAllComments', async (req, res) => {
  try {
    const client = await pool.connect();
    const query = `
      SELECT * FROM comment;
    `;

    const result = await client.query(query);

    if (result.rowCount > 0) {
      res.status(200).json(result.rows); // Возвращаем список всех комментариев
    } else {
      res.status(404).json({ message: 'No comments found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.put('/updateComment/:idComment', async (req, res) => {
  const idComment = req.params.idComment;
  const { description } = req.body;
  console.log(`Received update comment request for idComment: ${idComment}`);

  try {
    const client = await pool.connect();
    const query = `
    UPDATE comment SET description = $1 WHERE id_comment = $2 RETURNING *;

    `;
    const values = [description, idComment];

    const startTime = Date.now();
    const result = await client.query(query, values);
    const endTime = Date.now();
    console.log(`Query executed in ${endTime - startTime}ms`);

    if (result.rowCount > 0) {
      console.log('Comment updated successfully:', result);
      res.status(200).json({ message: 'Comment updated successfully' });
    } else {
      console.log('Comment not found');
      res.status(404).json({ message: 'Comment not found' });
    }
  } catch (error) {
    console.error('Error updating comment:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});
app.put('/updateItem/:idItem', async (req, res) => {
  const idItem = req.params.idItem;
  const newItemData = req.body; // Получаем новые данные элемента
  console.log(`Received update items request for idItem: ${idItem}`);

  try {
    const client = await pool.connect();
    const query = `
    UPDATE items SET name = $1, description = $2, cost = $3, count = $4, category = $5, raiting = $6 WHERE id = $7 RETURNING *;
    `;
    const values = [newItemData.name, newItemData.description, newItemData.cost, newItemData.count, newItemData.category, newItemData.rating, idItem];

    const startTime = Date.now();
    const result = await client.query(query, values);
    const endTime = Date.now();
    console.log(`Query executed in ${endTime - startTime}ms`);

    if (result.rowCount > 0) {
      console.log('Items updated successfully:', result);
      res.status(200).json({ message: 'Items updated successfully' });
    } else {
      console.log('Item not found');
      res.status(404).json({ message: 'Items not found' });
    }
  } catch (error) {
    console.error('Error updating item:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.get('/users', (req, res) => {
  pool.query('SELECT * FROM users', (error, result) => {
    if (error) {
      console.error(error);
      res.status(500).send('Error fetching users');
    } else {
      res.status(200).json(result.rows);
    }
  });
});
app.put('/changeRole/:id/:newRole', (req, res) => {
  const userId = req.params.id;
  const newRole = req.params.newRole;

  pool.query('UPDATE users SET role = $1 WHERE id = $2', [newRole, userId], (error, result) => {
  });
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});