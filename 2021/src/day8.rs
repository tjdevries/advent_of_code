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

#[derive(Debug, PartialEq, Eq, Hash)]
enum Numbers {
    Zero,
    One,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
}

#[derive(Debug, PartialEq, Eq, Hash)]
enum Letters {
    A,
    B,
    C,
    D,
    E,
    F,
    G,
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
    // let puzzle = include_str!("../data/8.example")
    //     .lines()
    //     .map(|l| l.split_once(" | ").unwrap().1)
    //     .flat_map(|output| output.split_whitespace().collect_vec())
    //     .filter(|display| match display.len() {
    //         2 | 3 | 4 | 7 => true,
    //         _ => false,
    //     })
    //     .collect_vec()
    //     .len();
    //

    let one = seg_set!(TopRight, BotRight);
    let four = seg_set!(TopLeft, Middle, TopRight, BotRight);
    let seven = seg_set!(Top, TopRight, BotRight);
    let eight = seg_set!(Top, TopLeft, TopRight, Middle, BotLeft, BotRight, Bottom);

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

    let puzzle = include_str!("../data/8.example")
        .lines()
        .next()
        .unwrap()
        .split(" | ")
        .map(|p| p.split_whitespace())
        .flatten()
        .collect_vec();
    println!("{:?}", puzzle);

    for item in puzzle {
        if item.len() == 2 {
            println!("{:?}", item);
            for c in item.chars() {
                for segment in all_segments.iter() {
                    if !one.contains(&segment) {
                        println!(" Removing: {:?}", segment);
                        possibilities.get_mut(&c).unwrap().remove(&segment);
                    }
                }
            }
        }
    }

    // let mut careful_examination = HashMap::new();
    // careful_examination.insert("abcdeg".to_string(), 0);
    // careful_examination.insert("ab".to_string(), 1);
    // careful_examination.insert("acdfg".to_string(), 2);
    // careful_examination.insert("abcdf".to_string(), 3);
    // careful_examination.insert("abef".to_string(), 4);
    // careful_examination.insert("bcdef".to_string(), 5);
    // careful_examination.insert("bcdefg".to_string(), 6);
    // careful_examination.insert("abd".to_string(), 7);
    // careful_examination.insert("abcdefg".to_string(), 8);
    // careful_examination.insert("abcdef".to_string(), 9);
    //
    // let puzzle = include_str!("../data/8.example")
    //     .lines()
    //     .map(|l| l.split_once(" | ").unwrap().1)
    //     .map(|output| {
    //         output
    //             .split_whitespace()
    //             .map(|letters| {
    //                 careful_examination.get(&letters.chars().sorted().collect::<String>())
    //             })
    //             .collect_vec()
    //     })
    //     .collect_vec();
    //
    // println!("{:?}", puzzle);
    //
    Ok(())
}
