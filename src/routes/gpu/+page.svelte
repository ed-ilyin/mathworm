<script lang="ts">
	let canvas: HTMLCanvasElement;
	(async () => {
		if (typeof navigator !== 'undefined') {
			let gpu = navigator.gpu;
			if (!gpu) {
				console.error('No GPU found');
			} else {
				let adapter = await gpu.requestAdapter();
				if (!adapter) {
					console.error('No adapter found');
				}
			}
		}
	})();
</script>

<canvas bind:this={canvas} />
