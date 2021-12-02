#[derive(Debug)]
enum Direction {
    Forward(usize),
    Down(usize),
    Up(usize),
}

#[derive(Debug)]
struct Location {
    horizontal: usize,
    depth: usize,
    aim: usize,
}

impl Location {
    fn new() -> Location {
        return Location {
            horizontal: 0,
            depth: 0,
            aim: 0,
        };
    }

    fn result(self) -> usize {
        self.horizontal * self.depth
    }
}

fn parse_line(line: &str) -> Option<Direction> {
    if let Some(parts) = line.split_once(" ") {
        let distance = parts.1.parse().unwrap();

        Some(match parts.0 {
            "forward" => Direction::Forward(distance),
            "down" => Direction::Down(distance),
            "up" => Direction::Up(distance),
            _ => panic!("Unhandled direction"),
        })
    } else {
        None
    }
}

fn main() {
    let part_1 = include_str!("../data/2.input")
        .split("\n")
        .filter_map(parse_line)
        .fold(Location::new(), |loc, dir| match dir {
            Direction::Forward(distance) => Location {
                horizontal: loc.horizontal + distance,
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
        .result();

    println!("{:?}", part_1);

    let part_2 = include_str!("../data/2.input")
        .split("\n")
        .filter_map(parse_line)
        .fold(Location::new(), |loc, dir| match dir {
            Direction::Forward(distance) => Location {
                horizontal: loc.horizontal + distance,
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
        .result();

    println!("{:?}", part_2);
}
