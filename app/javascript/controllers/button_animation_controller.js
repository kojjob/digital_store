class ButtonAnimationController extends Controller {
  static targets = ["defaultText", "successText"]
  
  animate() {
    // Animate the button when clicked
    this.defaultTextTarget.classList.add('opacity-0', '-translate-y-8')
    this.successTextTarget.classList.remove('opacity-0', 'translate-y-8')
    
    // Reset animation after 2 seconds
    setTimeout(() => {
      this.defaultTextTarget.classList.remove('opacity-0', '-translate-y-8')
      this.successTextTarget.classList.add('opacity-0', 'translate-y-8')
    }, 2000)
  }
}