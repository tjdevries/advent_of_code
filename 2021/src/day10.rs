use std::collections::HashMap;

use itertools::Itertools;

fn main() {
    println!(
        "Part 1: {}",
        include_str!("../data/10.input")
            .lines()
            .fold(0, |acc, line| {
                let opener = vec!['[', '(', '{', '<'];
                let mut closer = HashMap::new();
                closer.insert(']', '[');
                closer.insert(')', '(');
                closer.insert('}', '{');
                closer.insert('>', '<');

                let mut stack = Vec::new();
                for c in line.chars() {
                    if opener.contains(&c) {
                        stack.push(c);
                    } else {
                        let last = stack.last().unwrap();
                        let complete = closer.get(&c).unwrap();

                        if last == complete {
                            stack.pop();
                        } else {
                            if c == ')' {
                                return acc + 3;
                            } else if c == ']' {
                                return acc + 57;
                            } else if c == '}' {
                                return acc + 1197;
                            } else if c == '>' {
                                return acc + 25137;
                            } else {
                                panic!("Uhhmmm...");
                            }
                        }
                    }
                }

                acc
            })
    );

    let scores = include_str!("../data/10.input")
        .lines()
        .filter_map(|line| {
            let mut opener = HashMap::new();
            opener.insert('[', ']');
            opener.insert('(', ')');
            opener.insert('{', '}');
            opener.insert('<', '>');

            let mut closer = HashMap::new();
            closer.insert(']', '[');
            closer.insert(')', '(');
            closer.insert('}', '{');
            closer.insert('>', '<');

            let mut stack = Vec::new();
            for c in line.chars() {
                if opener.contains_key(&c) {
                    stack.push(c);
                } else {
                    let last = stack.last().unwrap();
                    let complete = closer.get(&c).unwrap();

                    if last == complete {
                        stack.pop();
                    } else {
                        // Skip bad ones
                        return None;
                    }
                }
            }

            if stack.len() > 0 {
                Some(stack.into_iter().rev().fold(0u64, |acc, c| {
                    acc * 5
                        + match c {
                            '(' => 1,
                            '[' => 2,
                            '{' => 3,
                            '<' => 4,
                            _ => unreachable!(),
                        }
                }))
            } else {
                panic!("I don't think this one is possible");
            }
        })
        .sorted()
        .collect_vec();

    println!("Part 2: {:?}", scores[scores.len() / 2]);
}
