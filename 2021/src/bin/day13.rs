use std::{collections::HashSet, str::FromStr};

use anyhow::Result;

#[derive(Debug)]
enum FoldDirection {
    X,
    Y,
}

#[derive(Debug)]
struct Fold {
    direction: FoldDirection,
    line: i32,
}

impl FromStr for Fold {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let s = s.replace("fold along ", "");
        let (dir, line) = s.split_once("=").unwrap();

        Ok(Fold {
            direction: match dir {
                "x" => FoldDirection::X,
                "y" => FoldDirection::Y,
                _ => panic!("Not possible for direction"),
            },
            line: line.parse()?,
        })
    }
}

fn main() -> Result<()> {
    let mut puzzle = include_str!("../data/13.input").lines();
    let mut dots = HashSet::<(i32, i32)>::new();
    while let Some(line) = puzzle.next() {
        if line.is_empty() {
            break;
        }

        let (x, y) = line.split_once(",").unwrap();
        dots.insert((x.parse()?, y.parse()?));
    }

    let mut folds: Vec<Fold> = Vec::new();
    while let Some(line) = puzzle.next() {
        folds.push(line.parse()?);
    }

    for fold in folds {
        dots = HashSet::from_iter(dots.into_iter().map(|(x, y)| match &fold.direction {
            &FoldDirection::X => {
                if x < fold.line {
                    (x, y)
                } else {
                    (2 * fold.line - x, y)
                }
            }
            &FoldDirection::Y => {
                if y < fold.line {
                    (x, y)
                } else {
                    (x, 2 * fold.line - y)
                }
            }
        }));
    }

    println!("Part 1: {}", dots.len());

    let mut max_x = 0;
    let mut max_y = 0;
    for (x, y) in dots.iter() {
        max_x = max_x.max(*x);
        max_y = max_y.max(*y);
    }

    for y in 0..=max_y {
        let mut line = String::new();
        for x in 0..=max_x {
            if dots.contains(&(x, y)) {
                line.push('█');
            } else {
                line.push(' ');
            }
        }

        println!("{}", line);
    }

    Ok(())
}
