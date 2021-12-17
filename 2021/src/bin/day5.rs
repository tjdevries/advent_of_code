use anyhow::Result;
use std::{collections::HashMap, ops::RangeInclusive, str::FromStr};

#[derive(Debug, PartialEq, Eq, Hash, Copy, Clone)]
struct Position(u32, u32);

impl FromStr for Position {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self> {
        let (x, y) = s.split_once(",").unwrap();
        Ok(Position(x.parse()?, y.parse()?))
    }
}

fn steps(start: u32, end: u32) -> Box<dyn Iterator<Item = u32>> {
    if start < end {
        Box::new(RangeInclusive::new(start, end))
    } else {
        Box::new(RangeInclusive::new(end, start).rev())
    }
}

fn betwixt(start: &Position, end: &Position, diagonal: bool) -> Vec<Position> {
    if start.0 != end.0 && start.1 != end.1 {
        if !diagonal {
            Vec::new()
        } else {
            steps(start.0, end.0)
                .zip(steps(start.1, end.1))
                .map(|(x, y)| Position(x, y))
                .collect()
        }
    } else {
        steps(start.0, end.0)
            .flat_map(|x| steps(start.1, end.1).map(move |y| Position(x, y)))
            .collect()
    }
}

#[derive(Debug)]
pub struct Line {
    start: Position,
    end: Position,
}

impl FromStr for Line {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self> {
        let (left, right) = s.split_once(" -> ").unwrap();

        Ok(Line {
            start: left.parse()?,
            end: right.parse()?,
        })
    }
}

fn get_dangerous_counts(lines: &Vec<Line>, diagonal: bool) -> u32 {
    let mut counts: HashMap<Position, u32> = HashMap::new();

    lines.iter().for_each(|item| {
        for pos in betwixt(&item.start, &item.end, diagonal) {
            counts.insert(pos, counts.get(&pos).unwrap_or(&0) + 1);
        }
    });

    counts
        .iter()
        .fold(0, |acc, (_, &count)| acc + if count > 1 { 1 } else { 0 })
}

fn main() -> Result<()> {
    let lines = aoc::read_one_per_line("./data/5.input")?;

    println!("{:?}", get_dangerous_counts(&lines, false));
    println!("{:?}", get_dangerous_counts(&lines, true));

    Ok(())
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_diagnoal_betwixt() {
        let start = Position(2, 0);
        let end = Position(0, 2);

        assert_eq!(
            vec![Position(2, 0), Position(1, 1), Position(0, 2)],
            betwixt(&start, &end, true)
        );
    }

    #[test]
    fn test_diagnoal_betwixt_example() {
        let start = Position(5, 5);
        let end = Position(8, 2);

        assert_eq!(
            vec![
                Position(5, 5),
                Position(6, 4),
                Position(7, 3),
                Position(8, 2)
            ],
            betwixt(&start, &end, true)
        );
    }
}
