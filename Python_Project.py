def compute_bmi(weight, height):
    """
    Function to calculate BMI (Body Mass Index) based on weight (in kilograms) and height (in meters).
    Formula: BMI = weight / (height ** 2)
    """
    try:
        bmi = weight / (height ** 2)
        return bmi
    except ZeroDivisionError:
        print("Error: Height cannot be zero.")
        return None


def analyze_bmi(bmi):
    """
    Function to analyze the BMI and provide feedback on the weight status.
    """
    if bmi < 18.5:
        return "Underweight"
    elif 18.5 <= bmi < 25:
        return "Normal weight"
    elif 25 <= bmi < 30:
        return "Overweight"
    else:
        return "Obese"

def get_measurement():
    weight = float(input("Enter weight in kilograms: "))
    while weight <= 0:
        print("Error: Weight must be positive. Try again")
        weight = float(input("Enter weight in kilograms: "))
    height = float(input("Enter height in meters: "))
    while height <= 0:
        print("Error: Height must be positive. Try again")
        height = float(input("Enter height in meters: "))
    return weight, height


def main():
    # Get user input for weight and height
    while True:
        try:
            weight, height = get_measurement()
            break
        except ValueError:
            print("Error: Please enter valid numerical values for weight and height.")

    # Calculate BMI
    bmi = compute_bmi(weight, height)

    # Analyze BMI
    weight_status = analyze_bmi(bmi)

    # Display the result
    if weight_status is not None:
        print(f"\nBMI: {bmi:.2f}")
        print(f"Weight Status: {weight_status}")
    else:
        print("Unable to calculate BMI. Please check your input.")

if __name__ == "__main__":
    main()