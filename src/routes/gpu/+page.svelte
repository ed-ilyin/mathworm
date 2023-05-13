<script lang="ts">
	let canvas: HTMLCanvasElement;
	if (typeof navigator !== 'undefined') {
		let gpu = navigator.gpu;
		if (!gpu) {
			console.error('WebGPU not supported');
		}
        async function adapter() { return await gpu.requestAdapter() }
        
	}
</script>

<canvas bind:this={canvas} />
