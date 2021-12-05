use std::str::FromStr;

#[derive(Debug)]
struct Line(u32);

impl FromStr for Line {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(Line(u32::from_str_radix(s, 2).unwrap()))
    }
}

impl Line {
    fn first_digit(&self) -> u32 {
        (0b10000 & self.0) >> 4
    }

    fn second_digit(&self) -> u32 {
        (0b1000 & self.0) >> 3
    }
}

#[derive(Debug)]
struct Rates {
    first_bits: i32,
    second_bits: i32,
}

impl Rates {
    fn gamma(&self) -> u32 {
        0 + if self.first_bits < 0 { 0 } else { 0b10000 }
            + if self.second_bits < 0 { 0 } else { 0b01000 }
    }
}

fn main() {
    let part_1 = include_str!("../data/3.example")
        .lines()
        .map(|f| f.parse::<Line>().unwrap())
        .fold(
            Rates {
                first_bits: 0,
                second_bits: 0,
            },
            |rates, line| Rates {
                first_bits: rates.first_bits + if line.first_digit() == 1 { 1 } else { -1 },
                second_bits: rates.second_bits + if line.second_digit() == 1 { 1 } else { -1 },
            },
        );

    println!("{:?}", part_1);
}
