use std::collections::{HashMap, HashSet};

use anyhow::Result;
use itertools::Itertools;

type Pair = (char, char);

fn step(
    rules: &HashMap<Pair, (Pair, Pair)>,
    combinations: HashMap<Pair, u64>,
) -> HashMap<Pair, u64> {
    let mut new = HashMap::new();

    for (pair, count) in combinations.into_iter() {
        if let Some(new_pairs) = rules.get(&pair) {
            *new.entry(new_pairs.0).or_insert(0) += count;
            *new.entry(new_pairs.1).or_insert(0) += count;
        } else {
            new.insert(pair, count);
        }
    }

    new
}

fn main() -> Result<()> {
    let mut puzzle = include_str!("../../data/14.input").lines();

    let template = puzzle.next().unwrap().to_string();
    let first_char = template.chars().next().unwrap();
    let end_char = template.chars().last().unwrap();

    // skip empty line
    puzzle.next();

    let mut rules = HashMap::new();
    while let Some(line) = puzzle.next() {
        let (pair, insert) = line.split_once(" -> ").unwrap();
        let mut pair = pair.chars();
        let left = pair.next().unwrap();
        let right = pair.next().unwrap();
        let new = insert.chars().next().unwrap();
        rules.insert((left, right), ((left, new), (new, right)));
    }

    let mut combinations = HashMap::new();
    template.chars().tuple_windows().for_each(|(left, right)| {
        *combinations.entry((left, right)).or_insert(0) += 1;
    });

    for _ in 0..40 {
        combinations = step(&rules, combinations)
    }

    let mut char_counts = HashMap::new();
    for c in [first_char, end_char] {
        *char_counts.entry(c).or_insert(0) += 1;
    }

    for ((c1, c2), count) in combinations.iter() {
        *char_counts.entry(*c1).or_insert(0) += *count;
        *char_counts.entry(*c2).or_insert(0) += *count;
    }

    let mut sorted_counts = char_counts.into_iter().sorted_by_key(|(_, count)| *count);

    let (_, least_count) = sorted_counts.next().unwrap().clone();
    let (_, most_count) = sorted_counts.last().unwrap().clone();

    println!("Answer: {}", most_count / 2 - least_count / 2);

    Ok(())
}
