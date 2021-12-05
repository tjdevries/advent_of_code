fn main() {
    let lines: Vec<Vec<u32>> = include_str!("../data/3.input")
        .lines()
        .map(|f| f.chars().map(|c| c.to_digit(2).unwrap()).collect())
        .collect();

    let digits = lines[0].len();
    let half = lines.len() as u32 / 2;
    let part_1: u32 = lines
        .iter()
        .fold(vec![0; digits], |mut v, l| {
            for i in 0..digits {
                v[i] += l[i]
            }

            v
        })
        .into_iter()
        .map(|d| if d > half { 1 } else { 0 })
        .fold(0, |res, digit| (res << 1) + digit);

    println!("{:?}", part_1 * (!part_1 << 32 - digits >> 32 - digits));

    let mut oxygen_values = lines.clone();
    for idx in 0..digits {
        let oxygen_half = (oxygen_values.len() as u32 + 1) / 2;
        let most_common = if oxygen_values
            .iter()
            .fold(0, |acc, digits| acc + digits[idx])
            < oxygen_half
        {
            0
        } else {
            1
        };

        oxygen_values = oxygen_values
            .into_iter()
            .filter(|digits| digits[idx] == most_common)
            .collect();

        if oxygen_values.len() == 1 {
            break;
        }
    }

    let mut co2_values = lines.clone();
    for idx in 0..digits {
        let most_common = if co2_values.iter().fold(0, |acc, digits| acc + digits[idx])
            < (co2_values.len() as u32 + 1) / 2
        {
            0
        } else {
            1
        };

        co2_values = co2_values
            .clone()
            .into_iter()
            .filter(|digits| digits[idx] != most_common)
            .collect();

        if co2_values.len() == 1 {
            break;
        }
    }

    let oxygen_value = oxygen_values[0]
        .iter()
        .fold(0, |res, digit| (res << 1) + digit);

    let c02_value = co2_values[0]
        .iter()
        .fold(0, |res, digit| (res << 1) + digit);

    println!("{:?}", oxygen_value * c02_value);
}
