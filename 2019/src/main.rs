use std::{cmp::max, fs};

fn calculate_fuel(mass: i64) -> i64 {
    return max(mass / 3 - 2, 0);
}

fn calculate_required_fuel(mass: i64) -> i64 {
    let base_fuel = calculate_fuel(mass);

    let mut required_fuel = base_fuel;
    let mut additional_fuel = calculate_fuel(base_fuel);
    while additional_fuel > 0 {
        required_fuel += additional_fuel;
        additional_fuel = calculate_fuel(additional_fuel);
    }

    return required_fuel;
}

fn main() {
    println!("Hello, world!");

    let contents = fs::read_to_string("./data/01.txt").expect("Plz work?");

    let mut numbers = Vec::new();
    let mut fuels: Vec<i64> = Vec::new();
    for line in contents.lines().into_iter() {
        let number = line.parse::<i64>().unwrap();

        numbers.push(number);
        fuels.push(calculate_required_fuel(number));
    }

    println!("Final Sum: {}", fuels.iter().sum::<i64>());
}

#[cfg(test)]
mod test {
    use crate::{calculate_fuel, calculate_required_fuel};

    #[test]
    fn test_1() {
        assert_eq!(calculate_fuel(12), 2);
    }

    #[test]
    fn test_2() {
        assert_eq!(calculate_fuel(14), 2);
    }

    #[test]
    fn test_3() {
        assert_eq!(calculate_fuel(1969), 654);
    }

    #[test]
    fn test_4() {
        assert_eq!(calculate_fuel(100756), 33583);
    }

    #[test]
    fn test_total() {
        assert_eq!(calculate_required_fuel(1969), 966);
    }
}
