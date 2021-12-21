use std::collections::{HashMap, HashSet};

use anyhow::Result;
use itertools::Itertools;

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
enum Segments {
    Top,
    TopLeft,
    TopRight,
    Middle,
    BotLeft,
    BotRight,
    Bottom,
}

macro_rules! set {
    ($($x:expr),+ $(,)?) => {{
        let mut s = HashSet::new();
        $(
            s.insert($x);
        )+
        s
    }};
}

macro_rules! seg_set {
    ($($x:ident),+ $(,)?) => (
        set![$(Segments::$x,)+]
    );
}

fn main() -> Result<()> {
    println!(
        "Part 1: {}",
        include_str!("../../data/8.input")
            .lines()
            .map(|l| l.split_once(" | ").unwrap().1)
            .flat_map(|output| output.split_whitespace().collect_vec())
            .filter(|display| match display.len() {
                2 | 3 | 4 | 7 => true,
                _ => false,
            })
            .collect_vec()
            .len()
    );

    let unique_numbers: Vec<HashSet<Segments>> = vec![
        seg_set!(Top, TopRight, TopLeft, BotLeft, BotRight, Bottom), // 0
        seg_set!(TopRight, BotRight),                                // 1
        seg_set!(Top, TopRight, Middle, BotLeft, Bottom),            // 2
        seg_set!(Top, TopRight, Middle, BotRight, Bottom),           // 3
        seg_set!(TopRight, Middle, TopLeft, BotRight),               // 4
        seg_set!(Top, TopLeft, Middle, BotRight, Bottom),            // 5
        seg_set!(Top, TopLeft, Middle, BotRight, Bottom, BotLeft),   // 6
        seg_set!(Top, TopRight, BotRight),                           // 7
        seg_set!(Top, TopLeft, TopRight, Middle, BotLeft, BotRight, Bottom), // 8
        seg_set!(Top, TopLeft, TopRight, Middle, BotRight, Bottom),  // 9
    ];

    println!(
        "Part 2: {}",
        include_str!("../../data/8.input")
            .lines()
            .fold(0, |acc, line| {
                let items = line
                    .split(" | ")
                    .map(|p| p.split_whitespace())
                    .flatten()
                    .map(|c| c.chars().sorted().collect::<String>())
                    .collect_vec();

                let all_segments: HashSet<Segments> =
                    seg_set!(Top, TopLeft, TopRight, Middle, BotLeft, BotRight, Bottom);

                let mut possibilities = HashMap::new();
                possibilities.insert('a', all_segments.clone());
                possibilities.insert('b', all_segments.clone());
                possibilities.insert('c', all_segments.clone());
                possibilities.insert('d', all_segments.clone());
                possibilities.insert('e', all_segments.clone());
                possibilities.insert('f', all_segments.clone());
                possibilities.insert('g', all_segments.clone());

                // Find Top.
                let one = items.iter().find(|item| item.len() == 2).unwrap();
                let four = items.iter().find(|item| item.len() == 4).unwrap();
                let seven = items.iter().find(|item| item.len() == 3).unwrap();

                let top = seven.chars().filter(|c| !one.contains(*c)).next().unwrap();

                for possibility in possibilities.values_mut() {
                    possibility.remove(&Segments::Top);
                }
                possibilities.insert(top, seg_set!(Top));

                // Handle One
                for c in one.chars() {
                    possibilities.insert(c, seg_set!(TopRight, BotRight));
                }

                // Handle Three
                let three = items
                    .iter()
                    .find(|item| {
                        if item.len() != 5 {
                            return false;
                        }

                        for c in seven.clone().chars() {
                            if !item.contains(c) {
                                return false;
                            }
                        }

                        return true;
                    })
                    .unwrap();

                for c in 'a'..='g' {
                    if seven.contains(c) {
                        continue;
                    }

                    if !three.contains(c) {
                        possibilities.get_mut(&c).unwrap().remove(&Segments::Middle);
                        possibilities.get_mut(&c).unwrap().remove(&Segments::Bottom);
                        continue;
                    } else {
                        if four.contains(c) {
                            possibilities.insert(c, seg_set!(Middle));
                        } else {
                            possibilities.insert(c, seg_set!(Bottom));
                        }
                    }
                }

                // Now we know TopLeft
                for c in 'a'..='g' {
                    possibilities
                        .get_mut(&c)
                        .unwrap()
                        .remove(&Segments::TopLeft);
                }

                for c in four.chars() {
                    if !three.contains(c) {
                        possibilities.insert(c, seg_set!(TopLeft));
                    }
                }

                // BotLeft is remaining only in one
                let botleft = possibilities
                    .clone()
                    .into_iter()
                    .find(|(_, val)| val.contains(&Segments::BotLeft))
                    .unwrap();

                possibilities.insert(botleft.0.clone(), seg_set!(BotLeft));

                let nine = items
                    .iter()
                    .find(|item| {
                        if item.len() != 6 {
                            return false;
                        }

                        for c in seven.clone().chars() {
                            if !item.contains(c) {
                                return false;
                            }
                        }

                        for c in four.clone().chars() {
                            if !item.contains(c) {
                                return false;
                            }
                        }

                        return true;
                    })
                    .unwrap();

                let six = items
                    .iter()
                    .find(|item| {
                        if item.len() != 6 {
                            return false;
                        }

                        if item == &nine {
                            return false;
                        }

                        for c in one.clone().chars() {
                            if !item.contains(c) {
                                return true;
                            }
                        }

                        return false;
                    })
                    .unwrap();

                let topright = one.chars().find(|c| !six.contains(*c)).unwrap();

                for c in 'a'..='g' {
                    possibilities
                        .get_mut(&c)
                        .unwrap()
                        .remove(&Segments::TopRight);
                }
                possibilities.insert(topright, seg_set!(TopRight));

                let mut mapping = HashMap::new();
                for (c, p) in possibilities.iter() {
                    mapping.insert(c, p.iter().next().unwrap());
                }

                let outputs = line
                    .split_once(" | ")
                    .unwrap()
                    .1
                    .split_whitespace()
                    .map(|item| {
                        item.chars().fold(HashSet::new(), |mut acc, c| {
                            acc.insert(*mapping.get(&c).unwrap().clone());
                            acc
                        })
                    })
                    .map(|mapped| {
                        for (idx, unique) in unique_numbers.iter().enumerate() {
                            if *unique == mapped {
                                return idx;
                            }
                        }

                        panic!("we done messed up, but rust is safe");
                    })
                    .fold(0, |acc, val| acc * 10 + val);

                acc + outputs
            })
    );

    Ok(())
}
