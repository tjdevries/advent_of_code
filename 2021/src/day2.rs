use std::str::FromStr;

use anyhow::Result;

#[derive(Debug)]
enum Direction {
    Forward(u64),
    Down(u64),
    Up(u64),
}

impl FromStr for Direction {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self> {
        if let Some((direction, distance)) = s.split_once(" ") {
            let distance = distance.parse()?;

            Ok(match direction {
                "forward" => Direction::Forward(distance),
                "down" => Direction::Down(distance),
                "up" => Direction::Up(distance),
                _ => panic!("Unhandled direction"),
            })
        } else {
            Err(anyhow::format_err!("could not split direction"))
        }
    }
}

#[derive(Debug)]
struct Location {
    distance: u64,
    depth: u64,
    aim: u64,
}

impl Location {
    fn new() -> Location {
        return Location {
            distance: 0,
            depth: 0,
            aim: 0,
        };
    }

    fn answer(self) -> u64 {
        self.distance * self.depth
    }
}

fn main() -> Result<()> {
    let filename = "./data/2.input";

    println!(
        "Part 1: {:?}",
        aoc::read_one_per_line::<Direction>(filename)?
            .iter()
            .fold(Location::new(), |loc, dir| match dir {
                Direction::Forward(distance) => Location {
                    distance: loc.distance + distance,
                    ..loc
                },
                Direction::Down(depth) => Location {
                    depth: loc.depth + depth,
                    ..loc
                },
                Direction::Up(depth) => Location {
                    depth: loc.depth - depth,
                    ..loc
                },
            })
            .answer()
    );

    println!(
        "Part 2: {:?}",
        aoc::read_one_per_line::<Direction>(filename)?
            .iter()
            .fold(Location::new(), |loc, dir| match dir {
                Direction::Forward(distance) => Location {
                    distance: loc.distance + distance,
                    depth: loc.depth + distance * loc.aim,
                    ..loc
                },
                Direction::Down(depth) => Location {
                    aim: loc.aim + depth,
                    ..loc
                },
                Direction::Up(depth) => Location {
                    aim: loc.aim - depth,
                    ..loc
                },
            })
            .answer()
    );

    Ok(())
}
