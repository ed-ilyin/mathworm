<script lang="ts">
	let showWardrobe = false;
</script>

<svelte:head>
	<title>TUC</title>
	<meta name="description" content="This is TUC game" />
</svelte:head>

<div id="buttons">
	<a href="tuc/game"><button class="big-button">play now &#x25B6;</button></a>
	<button class="big-button" on:click={() => (showWardrobe = true)}>wardrobe!</button>
</div>
<h1>MATH WORM</h1>
{#if showWardrobe}
	<div id="wardrobe">
		<div class="container">
			<div>select your skin</div>
			<button class="close" on:click={() => (showWardrobe = false)}>x</button>
		</div>
	</div>
{/if}

<style>
	#blue-rect {
		fill: rgb(0, 0, 255);
		stroke-width: 3;
		stroke: rgb(0, 0, 0);
	}
	.big-button {
		height: 129px;
		width: 200px;
		font-size: 39px;
		font-weight: 900;
		color: blanchedalmond;
		background-color: #8516ec;
	}
	#wardrobe {
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		width: 90%;
		height: 299px;
		background-color: blue;
		color: white;
		padding: 20px;
		z-index: 3;
	}
	.container {
		display: flex;
	}
	.close {
		margin-left: auto;
	}
</style>
