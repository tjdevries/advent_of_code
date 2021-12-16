use anyhow::Result;
use itertools::Itertools;

fn main() -> Result<()> {
    let size = 32;

    let lines = aoc::read_vec_per_line("./data/3.input", |c| char::to_digit(c, 2))?;

    let digits = lines[0].len();
    let half = lines.len() as u32 / 2;

    let mut sums = vec![0; digits];
    lines.iter().for_each(|line| {
        for i in 0..digits {
            sums[i] += line[i]
        }
    });

    let part_1: u32 = sums
        .into_iter()
        // if the count is greater than half of the numbers,
        // then it's the most common, so put a 1
        .map(|d| if d > half { 1 } else { 0 })
        // shift and add
        .fold(0, |res, digit| (res << 1) + digit);

    println!("{:?}", part_1 * (!part_1 << size - digits >> size - digits));

    // Part 2
    let filter_vals = |f: fn(u32, u32) -> bool| {
        let mut values = lines.clone();
        for idx in 0..digits {
            let line_values = values.iter().map(|digits| digits[idx]).collect_vec();

            let oxygen_half = (line_values.len() as u32 + 1) / 2;
            let oxygen_sum = line_values.iter().sum::<u32>();
            let most_common = if oxygen_sum < oxygen_half { 0 } else { 1 };

            // Filter to only the most common_digits
            values = values
                .into_iter()
                .filter(|value| f(value[idx], most_common))
                .collect();

            // Quit when we're down to only one thing left
            if values.len() == 1 {
                break;
            }
        }

        values
    };

    let oxygen_values = filter_vals(|digit, most_common| digit == most_common);
    let co2_values = filter_vals(|digit, most_common| digit != most_common);

    let oxygen_value = oxygen_values[0]
        .iter()
        .fold(0, |res, digit| (res << 1) + digit);

    let c02_value = co2_values[0]
        .iter()
        .fold(0, |res, digit| (res << 1) + digit);

    println!("{:?}", oxygen_value * c02_value);

    Ok(())
}
