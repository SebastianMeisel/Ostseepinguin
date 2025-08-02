use std::io::{BufRead,Write};

fn main() {
    let listener = std::net::TcpListener::bind("10.0.0.4:80").unwrap();
    for mut stream in listener.incoming().flatten() {
        let mut rdr = std::io::BufReader::new(&mut stream);
        let mut line = String::new();
        rdr.read_line(&mut line).unwrap();
        match line.trim().split(' ').collect::<Vec<_>>().as_slice() {
            ["GET", resource, "HTTP/1.1"] => {
                loop {
                    let mut line = String::new();
                    rdr.read_line(&mut line).unwrap();
                    if line.trim().is_empty() {break; }
                }
                let mut path = std::path::PathBuf::new();
                path.push("htdocs");
		let index = resource.find('?').unwrap_or(resource.len());
                path.push(resource[0..index].trim_start_matches("/"));
                if resource.ends_with("/") { path.push("index.html"); }
                stream.write_all(b"HTTP/1.1 200 OK\r\n").unwrap();
                stream.write_all(b"Server: Computerphile Rust\r\n").unwrap();
                stream.write_all(b"Content-type: text/html ; charset=utf-8\r\n\r\n").unwrap();
                stream.write_all(&std::fs::read(path).unwrap()).unwrap();
            }
            ["POST", _resource, "HTTP/1.1"] => {
                loop {
                    let mut line = String::new();
                    rdr.read_line(&mut line).unwrap();
	       	    println!("{}",line);
                    if line.trim().is_empty() { break; }
                }
                stream.write_all(b"HTTP/1.1 200 OK\r\n").unwrap();
                stream.write_all(b"Server: Computerphile Rust\r\n").unwrap();
                stream.write_all(b"Content-type: text/html ; charset=utf-8\r\n\r\n").unwrap();
                stream.write_all(b"<!DOCTYPE html>\r\n").unwrap();
                stream.write_all(b"<html><body><p>You wrote:\r\n").unwrap();
                stream.write_all(b"</p></body></html>\r\n").unwrap();
            }
	    ["inputString=",answer] => {
                loop {
                    let mut line = String::new();
                    rdr.read_line(&mut line).unwrap();
	       	    println!("{}",line);
                    if line.trim().is_empty() { break; }
                }
	    	stream.write_all(answer.as_bytes()).unwrap();
                stream.write_all(b"</p></body></html>\r\n").unwrap();
            }
            _ => {
                loop {
                    let mut line = String::new();
                    rdr.read_line(&mut line).unwrap();
	       	    println!("-{}",line);
                    if line.trim().is_empty() { break; }
                }
                stream.write_all(b"HTTP/1.1 200 OK\r\n").unwrap();
            }
        }
    }
}

