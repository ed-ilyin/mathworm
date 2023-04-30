<script lang="ts">
	import { onMount } from 'svelte';
	// import logo from '$lib/images/svelte-logo.svg';
	// import LogRow from './LogRow.svelte';
	export let kp = 0.01; // Proportional gain
	export let ki = 0.0002; // Integral gain
	export let kd = 0.1; // Derivative gain
	export let size = 32;

	let frame = 0;
	let mouse = [0, 0];
	let worm = [0, 0];
	let prevError = [0, 0];
	let integral = [0, 0];
	let velocity = [0, 0];
	let angle = 0;
	// PID

	function animate() {
		let error = mouse.map((n, i) => n - worm[i]); // Calculate error signal
		let derivative = error.map((n, i) => n - prevError[i]); // Calculate derivative term
		integral = integral.map((n, i) => n + error[i]); // Update integral term
		let pidOutput = error.map((n, i) => kp * n + ki * integral[i] + kd * derivative[i]); // Calculate PID output
		velocity = velocity.map((n, i) => n + pidOutput[i]); // Update velocity and worm position using PID output
		worm = worm.map((n, i) => n + velocity[i]);

		let diff = mouse.map((n, i) => worm[i] - n); // Calculate error signal
		angle = (Math.atan2(diff[1], diff[0]) * 180) / Math.PI - 90;
		prevError = error; // Store previous error for next iteration
	}

	function handleMouseMove(event: { clientX: number; clientY: number }) {
		mouse = [event.clientX, event.clientY];
	}

	function startAnimation() {
		frame = requestAnimationFrame(function animateFrame() {
			animate();
			frame = requestAnimationFrame(animateFrame);
		});
	}

	function stopAnimation() {
		cancelAnimationFrame(frame);
	}

	onMount(() => {
		document.addEventListener('mousemove', handleMouseMove);
		startAnimation();
		return () => {
			stopAnimation();
			document.removeEventListener('mousemove', handleMouseMove);
		};
	});
</script>

<!-- <table>
	<LogRow tag="mouse" vector={mouse} />
	<LogRow tag="integral" vector={integral} />
	<LogRow tag="prevError" vector={prevError} />
	<LogRow tag="velocity" vector={velocity} />
	<LogRow tag="worm" vector={worm} />
</table> -->
<!-- <div id="angle">angle: {Math.round(angle)}</div> -->
<div
	class="worm"
	style="width: {size}px; height: {size}px; top: {-size / 2}px; left: {-size /
		2}px; transform: translate({worm[0]}px, {worm[1]}px) rotate({angle}deg)"
>
	<slot />
</div>

<style>
	#angle {
		color: white;
	}
	.worm {
		position: absolute;
		z-index: -1;
	}
	table {
		color: white;
	}
</style>
