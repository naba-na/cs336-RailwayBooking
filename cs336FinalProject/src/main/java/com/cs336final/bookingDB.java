package com.cs336final;

import java.sql.Connection;
import java.sql.DriverManager;
//import java.sql.SQLException;
import java.sql.SQLException;

public class bookingDB{
	public bookingDB(){
		
	}
	
	public Connection getConnection() {
		String connectionURL = "jdbc:mysql://localhost:3306/bookingDB";
		Connection connection = null;
		
		//can put in better error checking later
		try {
			connection = DriverManager.getConnection(connectionURL,"root", "root");
		}catch(SQLException error){
			error.printStackTrace();
		}
		return connection;
	}
}
