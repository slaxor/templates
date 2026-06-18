fn main() {
    let name = std::env::args().nth(1).unwrap_or_else(|| "world".into());
    println!("{}", __PROJECT_NAME__::greet(&name));
}
